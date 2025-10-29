/*
 * audiocontroller.h / audiocontroller.cpp
 * ---------------------------------------
 * A minimal, signal-safe volume control class for embedded-vehicle HMIs.
 *
 * Maintainer: Abdulswamad Rama / GitHub: @abdswmdr
 *
 */

#include "audiocontroller.h"

AudioController::AudioController(QObject *parent)
    : QObject(parent), m_volumeLevel(10)
{
    // Initialize with a default volume level of 10 (low level)
}

int AudioController::volumeLevel() const
{
    return m_volumeLevel;
}

void AudioController::setVolumeLevel(int volumeLevel)
{
    if (m_volumeLevel != volumeLevel) {
        m_volumeLevel = volumeLevel;
        emit volumeLevelChanged(m_volumeLevel);
    }
}

void AudioController::incrementVolume(int val)
{
    int newVolume = m_volumeLevel + val;
    
    // Constrain volume within bounds (0-100)
    if (newVolume <= 0) {
        newVolume = 0;
    } else if (newVolume >= 100) {
        newVolume = 100;
    }
    
    setVolumeLevel(newVolume);
}
