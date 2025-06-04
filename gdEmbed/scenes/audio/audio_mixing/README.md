---
title: "Audio Mixing & Buses"
description: "Multi-track mixing with AudioBusLayout"
icon: "🎚️"
category: "audio"
---

# Audio Mixing & Buses

Master audio mixing techniques using multiple audio sources and AudioBusLayout for organized sound management across different audio categories.

## Overview

This demo demonstrates:
- Multiple AudioStreamPlayer instances
- AudioBusLayout with Master, Music, and SFX buses
- Individual track control and bus-level mixing
- Real-time volume adjustment for different audio categories
- Professional audio organization techniques

## Interactive Demo

{{gdEmbed[scenes/audio/audio_mixing/audio_mixing_demo]}}

## Key Concepts

### Audio Bus System
Godot's audio bus system allows hierarchical audio organization:
```gdscript
# Get or create audio buses
var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.add_bus("Music")
var sfx_bus = AudioServer.add_bus("SFX")

# Set bus routing
AudioServer.set_bus_send(music_bus, "Master")
AudioServer.set_bus_send(sfx_bus, "Master")
```

### Bus Routing
Each AudioStreamPlayer can be routed to a specific bus:
```gdscript
var player = AudioStreamPlayer.new()
player.bus = "Music"  # Route to Music bus
```

### Volume Control Hierarchy
- **Master Bus**: Controls overall game volume
- **Music Bus**: Controls background music volume
- **SFX Bus**: Controls sound effects volume
- **Individual Players**: Fine-tune specific tracks

## Audio Organization

### Bus Categories
The demo creates three main audio categories:

#### Master Bus
- Controls overall audio output
- Affects all other buses
- Ideal for master volume controls

#### Music Bus
- Background music and ambient sounds
- Usually lower priority than SFX
- Can be muted for quiet gameplay

#### SFX Bus  
- Sound effects and UI audio
- Higher priority than music
- Essential for gameplay feedback

### Multi-track Playback
Multiple audio files play simultaneously:
- Each track routes to appropriate bus
- Individual volume and playback control
- Synchronized or independent playback

## Controls

### Global Playback
- **Play All**: Start all audio tracks simultaneously
- **Stop All**: Stop all audio playback
- **Loop Toggle**: Enable looping for all tracks

### Bus Controls
- **Master Volume**: Overall output level (-30dB to +10dB)
- **Music Bus Volume**: Background music level (-30dB to +10dB)
- **SFX Bus Volume**: Sound effects level (-30dB to +10dB)

### Individual Track Controls
For each audio track:
- **Play/Stop**: Individual playback control
- **Volume Slider**: Per-track volume adjustment
- **Bus Assignment**: Visual indication of routing

### Keyboard Shortcuts
- `1` key: Play all tracks
- `2` key: Stop all tracks
- `3` key: Toggle loop mode

## Technical Implementation

### Bus Creation
```gdscript
func setup_audio_buses():
    # Add music bus
    if AudioServer.get_bus_index("Music") == -1:
        AudioServer.add_bus(1)
        AudioServer.set_bus_name(1, "Music")
        AudioServer.set_bus_send(1, "Master")
    
    # Add SFX bus  
    if AudioServer.get_bus_index("SFX") == -1:
        var sfx_index = AudioServer.get_bus_count()
        AudioServer.add_bus(sfx_index)
        AudioServer.set_bus_name(sfx_index, "SFX")
        AudioServer.set_bus_send(sfx_index, "Master")
```

### Player Setup
```gdscript
func setup_audio_players():
    for i in range(audio_streams.size()):
        var player = AudioStreamPlayer.new()
        player.stream = audio_streams[i]
        player.playback_type = AudioServer.PLAYBACK_TYPE_SAMPLE
        
        # Route to different buses
        player.bus = "Music" if i == 0 else "SFX"
        add_child(player)
```

### Volume Control
```gdscript
func _on_bus_volume_changed(bus_index: int, value: float):
    AudioServer.set_bus_volume_db(bus_index, value)
```

## Professional Mixing Tips

### Volume Levels
- **Master**: Usually 0dB (no boost)
- **Music**: -5dB to -10dB (background level)
- **SFX**: -5dB to 0dB (prominent for feedback)
- **UI Sounds**: -10dB to -15dB (subtle)

### Dynamic Range
- Maintain headroom to prevent clipping
- Use compression sparingly
- Keep peak levels below 0dB

### Audio Balance
- Music should support, not overwhelm gameplay
- SFX should be clear and immediate
- Dialogue should cut through the mix

## Use Cases

### Game Audio Mixing
- **Menu Music**: Routed to Music bus
- **Gameplay SFX**: Routed to SFX bus  
- **Ambient Sounds**: Mixed between Music/SFX
- **UI Feedback**: Separate UI bus (can be added)

### Interactive Applications
- **Background Audio**: Music bus with lower priority
- **User Feedback**: SFX bus with higher priority
- **Notifications**: Separate notification bus

### Audio Production
- **Layered Compositions**: Multiple tracks on different buses
- **Real-time Mixing**: Live adjustment of levels
- **Audio Mastering**: Final output processing

## Advanced Features

### Audio Effects (Limited on Web)
While Sample playback mode limits effects, you can still:
- Apply bus-level volume control
- Route audio through different output devices
- Implement custom audio processing

### Dynamic Bus Control
```gdscript
# Fade music during dialogue
func fade_music_for_dialogue():
    var tween = create_tween()
    var music_bus = AudioServer.get_bus_index("Music")
    tween.tween_method(
        func(db): AudioServer.set_bus_volume_db(music_bus, db),
        -5.0, -20.0, 1.0
    )
```

## Web Platform Considerations

### Performance
- Multiple AudioStreamPlayer instances use more resources
- Sample playback mode maintains good performance
- Limit total number of simultaneous players

### Browser Compatibility
- Basic bus routing works across all browsers
- Volume control is universally supported
- Complex effects may vary between platforms

## Best Practices

### Organization
- Plan your bus structure before implementation
- Use consistent naming conventions
- Document audio routing for team members

### Performance
- Pool audio players for frequently used sounds
- Limit simultaneous playback count
- Use appropriate audio formats for each bus

### User Experience
- Provide separate volume controls for different categories
- Save user audio preferences
- Test with different types of audio content

## Next Steps

- Try [Audio Synthesis](../audio_synthesis/) for procedural audio
- Explore [Positional Audio](../positional_audio/) for spatial effects
- Return to [Basic Audio](../basic_audio/) for fundamentals
