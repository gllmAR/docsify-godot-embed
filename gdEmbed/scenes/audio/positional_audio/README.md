---
title: "Positional Audio"
description: "2D spatial audio with distance and panning"
icon: "🎧"
category: "audio"
---

# Positional Audio

Experience 2D spatial audio with AudioStreamPlayer2D, featuring distance-based attenuation and stereo panning effects.

## Overview

This demo demonstrates:
- 2D positional audio with AudioStreamPlayer2D
- Distance-based volume attenuation
- Stereo panning based on position
- Real-time position visualization
- Interactive spatial audio controls

## Interactive Demo

{{gdEmbed[scenes/audio/positional_audio/positional_audio_demo]}}

## Key Concepts

### AudioStreamPlayer2D
The spatial audio node for 2D games:
```gdscript
var audio_player = AudioStreamPlayer2D.new()
audio_player.position = Vector2(100, 50)  # Set 3D position
audio_player.max_distance = 300.0         # Audio falloff distance
audio_player.attenuation = 1.0            # Distance curve
```

### Spatial Properties

#### Max Distance
Controls how far the audio can be heard:
```gdscript
audio_player.max_distance = 500.0  # Audible up to 500 pixels away
```

#### Attenuation Curve
Affects how volume decreases with distance:
- `1.0`: Linear falloff (default)
- `2.0`: Quadratic falloff (more realistic)
- `0.5`: Slower falloff (audio travels further)

#### Panning Strength
Controls stereo separation:
```gdscript
audio_player.panning_strength = 1.0  # Full stereo effect
audio_player.panning_strength = 0.0  # Mono (no panning)
```

## Position Control

### Real-time Movement
Move the audio source dynamically:
```gdscript
func _on_x_position_changed(value: float):
    source_position.x = value
    audio_player.position = source_position
```

### Distance Calculation
Monitor distance for UI feedback:
```gdscript
var distance = source_position.length()  # Distance from origin
var volume_factor = 1.0 - (distance / max_distance)
```

## Visualization

The demo includes a text-based visualization showing:
- 🎵 Sound source position
- 👂 Listener position (always at origin)
- 📏 Distance between source and listener

## Controls

### Playback Controls
- **Play Button**: Start positional audio
- **Stop Button**: Stop audio playback
- **Loop Toggle**: Enable continuous playback

### Spatial Controls
- **X Position**: Move sound source horizontally (-200 to 200)
- **Y Position**: Move sound source vertically (-150 to 150)
- **Max Distance**: Control audio falloff range (100 to 500)
- **Attenuation**: Adjust distance curve (0.1 to 3.0)
- **Panning Strength**: Control stereo separation (0.0 to 2.0)

### Keyboard Shortcuts
- `1` key: Play audio
- `2` key: Stop audio
- `3` key: Toggle loop mode

## Technical Implementation

### Setup Code
```gdscript
# Create and configure AudioStreamPlayer2D
audio_player = AudioStreamPlayer2D.new()
audio_player.stream = wav_stream
audio_player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE

# Configure spatial properties
audio_player.max_distance = 300.0
audio_player.attenuation = 1.0
audio_player.panning_strength = 1.0
```

### Position Updates
```gdscript
func update_position(new_position: Vector2):
    source_position = new_position
    audio_player.position = source_position
    update_visualization()
```

## Audio Design Tips

### Effective Use Cases
- **Ambient Sounds**: Environmental audio that changes with proximity
- **Sound Effects**: Explosions, impacts that feel positioned
- **Interactive Elements**: UI sounds that respond to cursor position
- **Game Audio**: Footsteps, dialogue, environmental sounds

### Distance Ranges
- **Close Range** (0-100px): Full volume, detailed audio
- **Medium Range** (100-300px): Audible with attenuation
- **Far Range** (300px+): Faint or silent

### Attenuation Curves
- **Linear (1.0)**: Even falloff, good for UI sounds
- **Quadratic (2.0)**: Realistic physics-based falloff
- **Custom**: Experiment with values for unique effects

## Web Platform Considerations

### Performance Notes
- AudioStreamPlayer2D uses more resources than basic AudioStreamPlayer
- Sample playback mode helps maintain performance
- Limit number of simultaneous positional audio sources

### Browser Limitations
- Some spatial effects may vary between browsers
- Mobile devices may have different audio processing
- Test across target platforms for consistency

### Optimization Tips
- Use positional audio sparingly for best performance
- Pre-load audio streams to avoid hitches
- Consider audio pooling for frequently used sounds

## Advanced Techniques

### Multiple Listeners
While this demo uses a fixed listener position, you can:
- Move the AudioListener2D node for camera-relative audio
- Create multiple audio zones with different properties
- Implement dynamic attenuation based on game state

### Audio Zones
Combine positional audio with:
- Reverb zones using AudioBusLayout
- Dynamic range compression
- Environmental audio effects

## Next Steps

- Explore [Audio Mixing](../audio_mixing/) for multiple sources
- Try [Audio Synthesis](../audio_synthesis/) for procedural sound
- Return to [Basic Audio](../basic_audio/) for fundamentals
