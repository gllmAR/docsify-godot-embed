---
title: "OGG Vorbis Playback"
description: "Compressed audio with seeking and loop controls"
icon: "🎶"
category: "audio"
---

# OGG Vorbis Playbook

Explore compressed audio playback with OGG Vorbis files, featuring advanced controls like seeking and playback position tracking.

## Overview

This demo demonstrates:
- Loading OGG Vorbis compressed audio files
- Advanced playback controls with seeking
- Real-time playback position tracking
- Compressed audio benefits for web deployment
- Sample playback mode optimization

## Interactive Demo

{{gdEmbed[scenes/audio/ogg_playback/ogg_playback_demo]}}

## Key Concepts

### OGG Vorbis Format
OGG Vorbis provides excellent compression with good quality:
- Smaller file sizes than WAV
- Open-source codec
- Ideal for music and longer audio clips
- Efficient streaming capabilities

### Seeking and Position Control
Unlike basic playback, OGG streams support seeking:
```gdscript
# Get current playback position
var position = audio_player.get_playback_position()

# Seek to specific time
audio_player.seek(30.0)  # Jump to 30 seconds
```

### AudioStreamOggVorbis Properties
```gdscript
var ogg_stream = load("res://assets/audio/music.ogg") as AudioStreamOggVorbis
var length = ogg_stream.get_length()  # Get total duration
```

### Real-time Position Tracking
Monitor playback progress for UI updates:
```gdscript
func _update_position():
    if audio_player.playing:
        var pos = audio_player.get_playback_position()
        var total = ogg_stream.get_length()
        var progress = pos / total
        position_slider.value = progress
```

## Compression Benefits

### File Size Comparison
- WAV: Uncompressed, larger files
- OGG: 80-90% smaller than WAV
- Quality: Minimal loss at standard bitrates

### Web Deployment Advantages
- Faster loading times
- Reduced bandwidth usage  
- Better user experience on mobile
- Maintains good audio quality

## Controls

### Playback Controls
- **Play/Pause Button**: Toggle audio playback
- **Stop Button**: Stop and reset to beginning
- **Loop Toggle**: Enable continuous playback

### Seeking Controls  
- **Position Slider**: Scrub through audio timeline
- **Skip Buttons**: Jump forward/backward by 10 seconds
- **Position Display**: Show current time and total duration

### Audio Parameters
- **Volume Slider**: Adjust output level
- **Pitch Slider**: Change playback speed

### Keyboard Shortcuts
- `1` key: Play/Pause audio
- `2` key: Stop audio
- `3` key: Toggle loop mode
- `4` key: Skip forward 10 seconds

## Technical Implementation

### Stream Loading
```gdscript
var ogg_stream = load_audio_resource("res://assets/audio/music.ogg")
if ogg_stream and ogg_stream is AudioStreamOggVorbis:
    audio_player.stream = ogg_stream
```

### Position Updates
```gdscript
# Timer-based position updates
var timer = Timer.new()
timer.wait_time = 0.1
timer.timeout.connect(_update_position)
timer.autostart = true
add_child(timer)
```

### Seeking Implementation
```gdscript
func _on_position_changed(value: float):
    if ogg_stream and not is_seeking:
        var seek_time = value * ogg_stream.get_length()
        audio_player.seek(seek_time)
```

## Best Practices

### When to Use OGG
- Background music
- Longer audio clips (>10 seconds)
- Non-critical audio where small quality loss is acceptable
- Web deployment where file size matters

### Quality Settings
- 128kbps: Good for voice and simple music
- 192kbps: Recommended for most music
- 256kbps: High quality for critical audio

## Web Platform Considerations

### Sample Mode Benefits
- Lower latency than streaming
- Consistent performance across browsers
- Better for interactive applications

### Browser Compatibility
- Excellent support in modern browsers
- Fallback options available for older browsers
- Progressive loading for better UX

## Next Steps

- Learn [Positional Audio](../positional_audio/) for spatial effects
- Explore [Audio Mixing](../audio_mixing/) for multiple tracks
- Try [Basic Audio](../basic_audio/) for uncompressed playback
