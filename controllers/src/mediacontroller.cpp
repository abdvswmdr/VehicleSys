#include "mediacontroller.h"
#include <QFileInfo>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QDebug>
#include <QRandomGenerator>

#ifdef HAVE_QT_MULTIMEDIA
#include <QMediaMetaData>
#include <QAudio>
#endif

MediaController::MediaController(QObject *parent)
    : QObject(parent)
#ifdef HAVE_QT_MULTIMEDIA
    , m_player(new QMediaPlayer(this))
    , m_playlist(new QMediaPlaylist(this))
#endif
    , m_positionTimer(new QTimer(this))
    , m_simulationTimer(new QTimer(this))
    , m_currentTitle("No Track")
    , m_currentArtist("Unknown Artist")
    , m_currentTime(0)
    , m_totalTime(0)
    , m_volume(50)
    , m_shuffle(false)
    , m_repeat(false)
    , m_isPlaying(false)
    , m_currentIndex(-1)
{
    // Supported audio formats
    m_supportedFormats << "*.mp3" << "*.mp4" << "*.wav" << "*.ogg" 
                       << "*.m4a" << "*.aac" << "*.flac" << "*.wma";

#ifdef HAVE_QT_MULTIMEDIA
    // Setup media player
    m_player->setPlaylist(m_playlist);
    m_player->setVolume(m_volume);
    
    // Ensure audio output is properly configured
    m_player->setAudioRole(QAudio::MusicRole);
    qDebug() << "MediaController: Qt Multimedia available, audio role set to MusicRole";
    qDebug() << "MediaController: Initial volume set to:" << m_volume;
    qDebug() << "MediaController: Player state:" << m_player->state();
    qDebug() << "MediaController: Media status:" << m_player->mediaStatus();

    // Connect signals
    connect(m_player, &QMediaPlayer::stateChanged, this, &MediaController::handleStateChanged);
    connect(m_player, &QMediaPlayer::positionChanged, this, &MediaController::handlePositionChanged);
    connect(m_player, &QMediaPlayer::durationChanged, this, &MediaController::handleDurationChanged);
    connect(m_player, &QMediaPlayer::currentMediaChanged, this, &MediaController::handleCurrentMediaChanged);
    connect(m_player, &QMediaPlayer::mediaStatusChanged, this, &MediaController::handleMediaStatusChanged);
    connect(m_player, static_cast<void(QMediaPlayer::*)(QMediaPlayer::Error)>(&QMediaPlayer::error),
            this, &MediaController::handleError);

    // Setup playlist
    m_playlist->setPlaybackMode(QMediaPlaylist::Sequential);
    
    qDebug() << "MediaController: Successfully initialized with Qt Multimedia";
    qDebug() << "MediaController: Available audio outputs should be checked in system";
#else
    qWarning() << "MediaController: Qt Multimedia not available - audio playback will not work";
    qWarning() << "To fix: Install qt5-multimedia package and rebuild the application";
    qDebug() << "MediaController: Falling back to simulation mode for UI testing";
    qDebug() << "MediaController: Audio will not actually play, but UI will function normally";
#endif

    // Position update timer
    connect(m_positionTimer, &QTimer::timeout, this, &MediaController::updateCurrentTime);
    m_positionTimer->setInterval(1000); // Update every second

    // Simulation timer for fallback mode
    connect(m_simulationTimer, &QTimer::timeout, this, &MediaController::simulatePlayback);
    m_simulationTimer->setInterval(1000); // Update every second

    // Auto-load music directory
    loadMusicDirectory();
}

MediaController::~MediaController()
{
#ifdef HAVE_QT_MULTIMEDIA
    if (m_player) {
        m_player->stop();
    }
#endif
}

// Property getters
bool MediaController::isPlaying() const
{
#ifdef HAVE_QT_MULTIMEDIA
    return m_player->state() == QMediaPlayer::PlayingState;
#else
    return m_isPlaying;
#endif
}

QString MediaController::currentTitle() const
{
    return m_currentTitle;
}

QString MediaController::currentArtist() const
{
    return m_currentArtist;
}

qint64 MediaController::currentTime() const
{
    return m_currentTime;
}

qint64 MediaController::totalTime() const
{
    return m_totalTime;
}

int MediaController::volume() const
{
    return m_volume;
}

QStringList MediaController::playlist() const
{
    return m_playlistFiles;
}

int MediaController::currentIndex() const
{
#ifdef HAVE_QT_MULTIMEDIA
    return m_playlist->currentIndex();
#else
    return m_currentIndex;
#endif
}

bool MediaController::shuffle() const
{
    return m_shuffle;
}

bool MediaController::repeat() const
{
    return m_repeat;
}

// Media control slots
void MediaController::play()
{
#ifdef HAVE_QT_MULTIMEDIA
    if (m_playlist->mediaCount() > 0) {
        qDebug() << "MediaController::play() - Starting playback";
        qDebug() << "MediaController: Current track index:" << m_playlist->currentIndex();
        qDebug() << "MediaController: Volume level:" << m_player->volume();
        qDebug() << "MediaController: Media count in playlist:" << m_playlist->mediaCount();
        m_player->play();
        m_positionTimer->start();
        qDebug() << "MediaController: Play command sent to QMediaPlayer";
    } else {
        qWarning() << "MediaController::play() - No media in playlist";
    }
#else
    if (m_playlistFiles.count() > 0) {
        m_isPlaying = true;
        m_simulationTimer->start();
        emit isPlayingChanged(m_isPlaying);
        qDebug() << "Playing (simulation):" << m_currentTitle;
    } else {
        qWarning() << "MediaController::play() - No tracks in simulation playlist";
    }
#endif
}

void MediaController::pause()
{
#ifdef HAVE_QT_MULTIMEDIA
    m_player->pause();
    m_positionTimer->stop();
#else
    m_isPlaying = false;
    m_simulationTimer->stop();
    emit isPlayingChanged(m_isPlaying);
    qDebug() << "Paused (simulation):" << m_currentTitle;
#endif
}

void MediaController::stop()
{
#ifdef HAVE_QT_MULTIMEDIA
    m_player->stop();
    m_positionTimer->stop();
#else
    m_isPlaying = false;
    m_simulationTimer->stop();
    m_currentTime = 0;
    emit isPlayingChanged(m_isPlaying);
    emit currentTimeChanged(m_currentTime);
    qDebug() << "Stopped (simulation):" << m_currentTitle;
#endif
}

void MediaController::togglePlayPause()
{
    if (isPlaying()) {
        pause();
    } else {
        play();
    }
}

void MediaController::next()
{
#ifdef HAVE_QT_MULTIMEDIA
    if (m_shuffle) {
        // Random next track
        int randomIndex = QRandomGenerator::global()->bounded(m_playlist->mediaCount());
        m_playlist->setCurrentIndex(randomIndex);
    } else {
        m_playlist->next();
    }
#else
    if (m_playlistFiles.count() > 0) {
        if (m_shuffle) {
            m_currentIndex = QRandomGenerator::global()->bounded(m_playlistFiles.count());
        } else {
            m_currentIndex = (m_currentIndex + 1) % m_playlistFiles.count();
        }
        loadCurrentTrack();
        if (m_isPlaying) {
            play();
        }
    }
#endif
}

void MediaController::previous()
{
#ifdef HAVE_QT_MULTIMEDIA
    m_playlist->previous();
#else
    if (m_playlistFiles.count() > 0) {
        m_currentIndex = m_currentIndex > 0 ? m_currentIndex - 1 : m_playlistFiles.count() - 1;
        loadCurrentTrack();
        if (m_isPlaying) {
            play();
        }
    }
#endif
}

// Playlist management
void MediaController::loadMusicDirectory(const QString &path)
{
    QString musicPath = path.isEmpty() ? "music" : path;
    
    // Try relative path first
    QDir musicDir(musicPath);
    if (!musicDir.exists()) {
        // Try in application directory (build folder)
        musicPath = QCoreApplication::applicationDirPath() + "/music";
        musicDir.setPath(musicPath);
    }
    
    if (!musicDir.exists()) {
        // Try in project root (parent of build directory)
        QString projectRoot = QCoreApplication::applicationDirPath() + "/../music";
        musicDir.setPath(projectRoot);
        if (musicDir.exists()) {
            musicPath = QDir(projectRoot).absolutePath();
        }
    }
    
    if (!musicDir.exists()) {
        qWarning() << "Music directory not found:" << musicPath;
        emit mediaError("Music directory not found: " + musicPath);
        return;
    }

    clearPlaylist();
    
    QStringList audioFiles = getSupportedAudioFiles(musicDir);
    
    qDebug() << "Found" << audioFiles.size() << "audio files in" << musicPath;
    
    for (const QString &filePath : audioFiles) {
        addFile(filePath);
    }
    
#ifdef HAVE_QT_MULTIMEDIA
    if (m_playlist->mediaCount() > 0) {
        m_playlist->setCurrentIndex(0);
        qDebug() << "Loaded" << m_playlist->mediaCount() << "tracks";
    }
#else
    if (m_playlistFiles.count() > 0) {
        m_currentIndex = 0;
        loadCurrentTrack();
        qDebug() << "Loaded" << m_playlistFiles.count() << "tracks (simulation mode)";
    }
#endif
}

void MediaController::addFile(const QString &filePath)
{
#ifdef HAVE_QT_MULTIMEDIA
    QUrl url = QUrl::fromLocalFile(filePath);
    m_playlist->addMedia(QMediaContent(url));
#endif
    
    QFileInfo fileInfo(filePath);
    m_playlistFiles.append(fileInfo.baseName());
    
    emit playlistChanged();
}

void MediaController::removeFile(int index)
{
#ifdef HAVE_QT_MULTIMEDIA
    if (index >= 0 && index < m_playlist->mediaCount()) {
        m_playlist->removeMedia(index);
        m_playlistFiles.removeAt(index);
        emit playlistChanged();
    }
#else
    if (index >= 0 && index < m_playlistFiles.count()) {
        m_playlistFiles.removeAt(index);
        if (m_currentIndex >= index && m_currentIndex > 0) {
            m_currentIndex--;
        }
        emit playlistChanged();
    }
#endif
}

void MediaController::clearPlaylist()
{
#ifdef HAVE_QT_MULTIMEDIA
    m_playlist->clear();
#endif
    m_playlistFiles.clear();
    m_currentIndex = -1;
    emit playlistChanged();
}

void MediaController::playTrack(int index)
{
#ifdef HAVE_QT_MULTIMEDIA
    if (index >= 0 && index < m_playlist->mediaCount()) {
        m_playlist->setCurrentIndex(index);
        play();
    }
#else
    if (index >= 0 && index < m_playlistFiles.count()) {
        m_currentIndex = index;
        loadCurrentTrack();
        play();
    }
#endif
}

// Settings
void MediaController::setVolume(int volume)
{
    int clampedVolume = qBound(0, volume, 100);
    qDebug() << "MediaController::setVolume() - Requested:" << volume << "Clamped:" << clampedVolume;
    if (m_volume != clampedVolume) {
        m_volume = clampedVolume;
#ifdef HAVE_QT_MULTIMEDIA
        m_player->setVolume(m_volume);
        qDebug() << "MediaController: Volume set on QMediaPlayer to:" << m_volume;
        qDebug() << "MediaController: Actual player volume now:" << m_player->volume();
#else
        qDebug() << "MediaController: Volume set in simulation mode to:" << m_volume;
#endif
        emit volumeChanged(m_volume);
    }
}

void MediaController::setShuffle(bool shuffle)
{
    if (m_shuffle != shuffle) {
        m_shuffle = shuffle;
#ifdef HAVE_QT_MULTIMEDIA
        if (shuffle) {
            m_playlist->setPlaybackMode(QMediaPlaylist::Random);
        } else if (m_repeat) {
            m_playlist->setPlaybackMode(QMediaPlaylist::Loop);
        } else {
            m_playlist->setPlaybackMode(QMediaPlaylist::Sequential);
        }
#endif
        emit shuffleChanged(m_shuffle);
    }
}

void MediaController::setRepeat(bool repeat)
{
    if (m_repeat != repeat) {
        m_repeat = repeat;
#ifdef HAVE_QT_MULTIMEDIA
        if (repeat) {
            m_playlist->setPlaybackMode(m_shuffle ? QMediaPlaylist::Random : QMediaPlaylist::Loop);
        } else {
            m_playlist->setPlaybackMode(m_shuffle ? QMediaPlaylist::Random : QMediaPlaylist::Sequential);
        }
#endif
        emit repeatChanged(m_repeat);
    }
}

void MediaController::seek(qint64 position)
{
#ifdef HAVE_QT_MULTIMEDIA
    m_player->setPosition(position);
#else
    m_currentTime = qBound(0LL, position, m_totalTime);
    emit currentTimeChanged(m_currentTime);
#endif
}

// Private slots
#ifdef HAVE_QT_MULTIMEDIA
void MediaController::handleStateChanged(QMediaPlayer::State state)
{
    emit isPlayingChanged(state == QMediaPlayer::PlayingState);
    
    if (state == QMediaPlayer::PlayingState) {
        m_positionTimer->start();
    } else {
        m_positionTimer->stop();
    }
}

void MediaController::handlePositionChanged(qint64 position)
{
    if (m_currentTime != position) {
        m_currentTime = position;
        emit currentTimeChanged(m_currentTime);
    }
}

void MediaController::handleDurationChanged(qint64 duration)
{
    if (m_totalTime != duration) {
        m_totalTime = duration;
        emit totalTimeChanged(m_totalTime);
    }
}

void MediaController::handleCurrentMediaChanged(const QMediaContent &content)
{
    if (content.isNull()) {
        m_currentTitle = "No Track";
        m_currentArtist = "Unknown Artist";
    } else {
        QString filePath = content.canonicalUrl().toLocalFile();
        extractMetadata(filePath);
    }
    
    emit currentTitleChanged(m_currentTitle);
    emit currentArtistChanged(m_currentArtist);
    emit currentIndexChanged(m_playlist->currentIndex());
}

void MediaController::handleMediaStatusChanged(QMediaPlayer::MediaStatus status)
{
    if (status == QMediaPlayer::InvalidMedia) {
        emit mediaError("Invalid media file");
    } else if (status == QMediaPlayer::EndOfMedia) {
        // Handle end of track
        if (!m_repeat && !m_shuffle && m_playlist->currentIndex() == m_playlist->mediaCount() - 1) {
            // End of playlist
            stop();
        }
    }
}

void MediaController::handleError(QMediaPlayer::Error error)
{
    QString errorString;
    switch (error) {
    case QMediaPlayer::ResourceError:
        errorString = "Resource error - media file not found or corrupt";
        break;
    case QMediaPlayer::FormatError:
        errorString = "Format error - unsupported media format";
        break;
    case QMediaPlayer::NetworkError:
        errorString = "Network error";
        break;
    case QMediaPlayer::AccessDeniedError:
        errorString = "Access denied - insufficient permissions";
        break;
    case QMediaPlayer::ServiceMissingError:
        errorString = "Service missing - required media service not available. Check if audio drivers are installed.";
        break;
    default:
        errorString = "Unknown media error";
        break;
    }
    
    qWarning() << "Media player error:" << errorString;
    qWarning() << "Volume level:" << m_volume << "Audio role: Music";
    qWarning() << "Available audio devices should be checked in system settings";
    emit mediaError(errorString);
}
#endif

void MediaController::updateCurrentTime()
{
#ifdef HAVE_QT_MULTIMEDIA
    // This ensures regular updates even if positionChanged isn't emitted frequently
    qint64 position = m_player->position();
    if (m_currentTime != position) {
        m_currentTime = position;
        emit currentTimeChanged(m_currentTime);
    }
#else
    // Fallback mode handles time in simulatePlayback()
#endif
}

void MediaController::simulatePlayback()
{
    if (m_isPlaying && m_currentTime < m_totalTime) {
        m_currentTime += 1000; // Increment by 1 second (1000ms)
        emit currentTimeChanged(m_currentTime);
    } else if (m_currentTime >= m_totalTime && m_isPlaying) {
        // End of track
        if (m_repeat || (m_currentIndex < m_playlistFiles.count() - 1) || m_shuffle) {
            next();
        } else {
            stop();
        }
    }
}

void MediaController::loadCurrentTrack()
{
    if (m_currentIndex >= 0 && m_currentIndex < m_playlistFiles.count()) {
        QString fileName = m_playlistFiles[m_currentIndex];
        m_currentTitle = getFileTitle(fileName);
        m_currentArtist = getFileArtist(fileName);
        
        // Set a realistic duration for simulation
        m_totalTime = (180 + QRandomGenerator::global()->bounded(120)) * 1000; // 3-5 minutes in ms
        m_currentTime = 0;
        
        emit currentTitleChanged(m_currentTitle);
        emit currentArtistChanged(m_currentArtist);
        emit currentIndexChanged(m_currentIndex);
        emit totalTimeChanged(m_totalTime);
        emit currentTimeChanged(m_currentTime);
    }
}

// Private helper methods
void MediaController::extractMetadata(const QString &filePath)
{
    m_currentTitle = getFileTitle(filePath);
    m_currentArtist = getFileArtist(filePath);
    
#ifdef HAVE_QT_MULTIMEDIA
    // Try to get metadata from QMediaPlayer if available
    if (m_player->isMetaDataAvailable()) {
        QString title = m_player->metaData(QMediaMetaData::Title).toString();
        QString artist = m_player->metaData(QMediaMetaData::Author).toString();
        
        if (!title.isEmpty()) m_currentTitle = title;
        if (!artist.isEmpty()) m_currentArtist = artist;
    }
#endif
}

QString MediaController::getFileTitle(const QString &filePath)
{
    QFileInfo fileInfo(filePath);
    QString baseName = fileInfo.baseName();
    
    // Simple parsing for common filename patterns
    if (baseName.contains(" - ")) {
        QStringList parts = baseName.split(" - ");
        if (parts.size() >= 2) {
            return parts[1].trimmed(); // Assume "Artist - Title" format
        }
    }
    
    return baseName;
}

QString MediaController::getFileArtist(const QString &filePath)
{
    QFileInfo fileInfo(filePath);
    QString baseName = fileInfo.baseName();
    
    // Simple parsing for common filename patterns
    if (baseName.contains(" - ")) {
        QStringList parts = baseName.split(" - ");
        if (parts.size() >= 2) {
            return parts[0].trimmed(); // Assume "Artist - Title" format
        }
    }
    
    return "Unknown Artist";
}

QStringList MediaController::getSupportedAudioFiles(const QDir &dir)
{
    QStringList files;
    
    QFileInfoList fileList = dir.entryInfoList(m_supportedFormats, QDir::Files | QDir::Readable, QDir::Name);
    
    for (const QFileInfo &fileInfo : fileList) {
        files.append(fileInfo.absoluteFilePath());
    }
    
    return files;
}