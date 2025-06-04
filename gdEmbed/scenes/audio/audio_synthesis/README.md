---
title: "Audio Synthesis"
description: "Procedural waveform generation and synthesis"
icon: "🎛️"
category: "audio"
---

# Audio Synthesis

Experiment with basic procedural audio generation using AudioStreamGenerator for real-time waveform synthesis.

## Overview

This demo demonstrates:
- Real-time audio synthesis with AudioStreamGenerator
- Multiple waveform types (Sine, Square, Sawtooth, Triangle)
- Interactive frequency and amplitude control
- Procedural audio generation techniques
- Web platform limitations and considerations

## Interactive Demo

{{gdEmbed[scenes/audio/audio_synthesis/audio_synthesis_demo]}}

## ⚠️ Web Platform Limitations

**Important**: Audio synthesis has significant limitations on web platforms:
- AudioStreamGenerator may not work optimally with Sample playback mode
- Real-time synthesis performance varies between browsers
- Consider pre-generated samples for production web games
- This demo primarily serves educational purposes

## Key Concepts

### AudioStreamGenerator
The foundation for procedural audio in Godot:
```gdscript
var audio_generator = AudioStreamGenerator.new()
audio_generator.sample_rate = 44100
audio_generator.buffer_length = 0.1  # 100ms buffer

var audio_player = AudioStreamPlayer.new()
audio_player.stream = audio_generator
```

### Waveform Generation
Different wave types create distinct sounds:

#### Sine Wave
- Pure tone, smooth sound
- Foundation of audio synthesis
- No harmonics, clean frequency

#### Square Wave
- Sharp, digital sound
- Rich in odd harmonics
- Common in retro game audio

#### Sawtooth Wave
- Bright, buzzy sound
- Rich in all harmonics
- Good for bass sounds

#### Triangle Wave
- Softer than square wave
- Contains odd harmonics (weaker than square)
- Mellower sound

### Real-time Generation
Audio samples are generated in real-time:
```gdscript
func generate_sample() -> float:
    var sample: float
    match wave_type:
        0: sample = sin(phase)  # Sine wave
        1: sample = 1.0 if sin(phase) > 0.0 else -1.0  # Square
        2: sample = (phase / PI) - 1.0  # Sawtooth
        3: sample = triangle_calculation(phase)  # Triangle
    return sample * amplitude
```

## Controls

### Playback Controls
- **Play Button**: Start audio synthesis
- **Stop Button**: Stop synthesis and reset
- **Wave Type Buttons**: Select waveform (Sine, Square, Sawtooth, Triangle)

### Synthesis Parameters
- **Frequency Slider**: Control pitch (220Hz to 880Hz)
- **Amplitude Slider**: Control waveform strength (0.0 to 1.0)
- **Volume Slider**: Control output volume (-30dB to 0dB)

### Keyboard Shortcuts
- `1` key: Start synthesis
- `2` key: Stop synthesis
- `3` key: Cycle through wave types

## Technical Implementation

### Buffer Management
```gdscript
func generate_audio_samples():
    var frames_to_fill = playback.get_frames_available()
    var samples = PackedFloat32Array()
    samples.resize(frames_to_fill * 2)  # Stereo
    
    for i in range(frames_to_fill):
        var sample_value = generate_sample()
        samples[i * 2] = sample_value      # Left
        samples[i * 2 + 1] = sample_value  # Right
    
    playback.push_buffer(samples)
```

### Phase Management
Maintain continuous waveform phase:
```gdscript
phase += (frequency * 2.0 * PI) / sample_rate
if phase > 2.0 * PI:
    phase -= 2.0 * PI
```

### Waveform Algorithms
Each wave type uses different mathematical functions:
```gdscript
# Triangle wave calculation
func triangle_calculation(phase_val: float) -> float:
    var normalized = phase_val / (2.0 * PI)
    if normalized < 0.5:
        return (normalized * 4.0) - 1.0
    else:
        return 3.0 - (normalized * 4.0)
```

## Audio Theory

### Frequency and Pitch
- **220Hz**: A3 note
- **440Hz**: A4 note (concert pitch)
- **880Hz**: A5 note (one octave up)
- Doubling frequency = one octave higher

### Harmonics and Timbre
- **Sine**: Pure fundamental frequency
- **Square/Sawtooth**: Rich harmonic content
- **Triangle**: Selective harmonic content
- Harmonics determine the "color" of sound

### Amplitude and Volume
- **Amplitude**: Waveform strength (0.0 to 1.0)
- **Volume**: Output level in decibels
- **Headroom**: Keep amplitude below 1.0 to prevent clipping

## Practical Applications

### Game Audio Uses
- **Sound Effects**: Explosions, zaps, beeps
- **Music**: Bass lines, lead synths, percussion
- **Feedback**: UI sounds, notifications
- **Procedural**: Dynamic, context-sensitive audio

### Educational Value
- Understanding audio fundamentals
- Learning synthesis concepts
- Experimenting with sound design
- Preparing for advanced audio programming

## Limitations and Alternatives

### Web Platform Issues
- Inconsistent AudioStreamGenerator support
- Performance varies significantly
- Latency and timing issues
- Limited real-time capabilities

### Recommended Alternatives for Web
1. **Pre-rendered Samples**: Generate audio offline, load as WAV/OGG
2. **Layered Samples**: Combine multiple short samples
3. **Parameterized Samples**: Multiple versions at different pitches
4. **Web Audio API**: Direct browser audio programming (advanced)

### When to Use Synthesis
- Educational/experimental projects
- Desktop/mobile platforms (better support)
- Specific procedural audio needs
- Prototype development

## Advanced Synthesis Concepts

### Envelope Shaping (ADSR)
While not implemented in this basic demo:
- **Attack**: How quickly sound starts
- **Decay**: Initial volume reduction
- **Sustain**: Held volume level
- **Release**: How quickly sound stops

### Modulation
Techniques for dynamic sound:
- **Frequency Modulation**: Vibrato effects
- **Amplitude Modulation**: Tremolo effects
- **Phase Modulation**: Complex timbres

### Filtering
Shape frequency content:
- **Low-pass**: Remove high frequencies
- **High-pass**: Remove low frequencies
- **Band-pass**: Isolate frequency ranges

## Best Practices

### Performance
- Keep buffer sizes reasonable (50-200ms)
- Limit simultaneous synthesis voices
- Use efficient waveform algorithms
- Monitor CPU usage

### Audio Quality
- Avoid clipping (keep amplitude < 1.0)
- Smooth parameter changes to prevent clicks
- Consider anti-aliasing for high frequencies
- Test across different sample rates

### User Experience
- Provide intuitive controls
- Give immediate audio feedback
- Include presets for common sounds
- Document synthesis parameters

## Next Steps

- Explore [Audio Mixing](../audio_mixing/) for combining synthesized and sampled audio
- Try [Positional Audio](../positional_audio/) for spatial synthesis
- Return to [Basic Audio](../basic_audio/) for sample-based approaches
- Consider external synthesis tools for complex audio generation
