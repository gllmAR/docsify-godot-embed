---
title: "Audio Systems"
description: "Master audio playback, effects, and spatial sound"
icon: "🔊"
category: "audio"
---

# Audio Systems

Learn how to implement various audio features in Godot with these interactive demonstrations. All demos are optimized for web deployment using Godot's Sample playback mode for low latency.

## Audio Tutorials

### [Basic Audio Playback](basic_audio/)
Learn the fundamentals of loading and playing WAV audio files with volume and pitch controls.

### [OGG Vorbis Playback](ogg_playback/)
Discover how to use compressed OGG Vorbis audio files with seeking and playback position controls.

### [Positional Audio](positional_audio/)
Explore 2D spatial audio with AudioStreamPlayer2D for distance-based attenuation and panning effects.

### [Audio Mixing & Buses](audio_mixing/)
Master audio mixing techniques using multiple audio sources and AudioBusLayout for organized sound management.

### [Audio Synthesis](audio_synthesis/)
Experiment with basic procedural audio generation using AudioStreamGenerator (limited on web platforms).

## Web Platform Considerations

When deploying audio to web platforms, keep these important points in mind:

### Sample Playback Mode
- All demos use `AudioServer.PLAYBACK_TYPE_SAMPLE` for optimal web performance
- Provides lower latency compared to streaming mode
- Better suited for interactive audio applications

### Limitations on Web
- **AudioEffects**: Not supported in Sample playback mode
- **Reverberation and Doppler**: Limited or unavailable
- **Procedural Audio**: AudioStreamGenerator has reduced functionality
- **Positional Audio**: Some features may not work as expected

### Best Practices
- Use compressed formats (OGG) for music and longer audio clips
- Use uncompressed formats (WAV) for short sound effects
- Pre-generate complex audio rather than using real-time synthesis
- Test thoroughly on target web browsers

## Interactive Controls

Each demo includes:
- **Play/Stop Controls**: Basic playback management
- **Volume/Pitch Sliders**: Real-time audio parameter adjustment
- **Keyboard Shortcuts**: Quick access to common functions
  - `1` key: Play/Start
  - `2` key: Stop
  - `3` key: Toggle loop or switch modes
  - `4` key: Additional demo-specific functions

## Getting Started

Choose any tutorial above to begin exploring Godot's audio capabilities. Each demo builds upon previous concepts, so starting with Basic Audio Playback is recommended for beginners.
