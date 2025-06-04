---
title: "Advance Audio Player"
description: "Player with waveform visualization and precise loop controls"
icon: "🎵"
category: "audio"
---

# Advance Audio Player

A sophisticated audio sample player with professional-grade waveform visualization, timeline controls, and precise loop point manipulation.

## Overview

This demo demonstrates:
- **Professional waveform display** with grid lines and time markers
- **Interactive timeline** with click-to-seek functionality
- **Visual loop handles** for precise loop point control
- **Real-time playback position** indicator
- Volume and pitch controls with professional styling
- **Click-based loop point setting** (right-click for loop start, Shift+right-click for loop end)
- Platform-optimized audio playback
- **Enhanced demo audio** with chord progression for better visualization

## Interactive Demo

{{gdEmbed[scenes/audio/basic_audio/basic_audio_demo]}}

## Key Features

### Professional Waveform Display
- **High-contrast visualization** with dark background and bright cyan waveform
- **Grid lines every 0.5 seconds** for precise timing reference
- **Peak detection rendering** for accurate amplitude representation
- **Loop region highlighting** with yellow overlay when loop is active
- **Green/red loop boundary markers** for visual feedback

### Interactive Timeline Controls
- **Click anywhere on waveform** to seek to that position
- **Large draggable handles** at the bottom of the waveform for precise loop control
- **Visual hover feedback** with cursor changes and handle highlighting
- **Real-time drag feedback** showing current time values
- **Alternative right-click method**: Right-click for loop start, Shift+right-click for loop end
- **Time ruler** with tick marks and time labels

### Enhanced Loop Point Interaction
- **Large 20px handles** for easy clicking and dragging
- **IN point at top** (green handle) - marks the loop start position
- **OUT point at bottom** (red handle) - marks the loop end position
- **Loop region handle** (blue handle) - moves both points simultaneously while maintaining their distance
- **Precision control** - allows loops as small as 1 sample
- **Expanded hit areas** for better accessibility on touch devices
- **Visual hover states** with color changes and size indicators
- **Drag-and-drop functionality** with real-time feedback
- **Automatic cursor changes** (resize cursor for individual points, move cursor for region)
- **Time display** showing precise loop point values during interaction (millisecond precision)

### Transport Controls
- **Play/Pause button** (▶/⏸) - toggles between play and pause
- **Stop button** (⏹) - stops playback and resets to beginning
- **Loop toggle button** (🔄) - enables/disables looping with visual feedback (yellow when active)
- **Loop type button** (🔄/↔️) - cycles between loop types:
  - 🔄 Forward Loop (default color)
  - ↔️ Ping-Pong Loop (orange color)
- **Real-time time display** showing current position and total duration

### Audio Processing
```gdscript
# Professional loop point handling
func _on_loop_toggled(pressed: bool):
	if pressed:
		var sample_rate = wav_stream.mix_rate
		wav_stream.loop_begin = int(loop_start * sample_rate)
		wav_stream.loop_end = int(loop_end * sample_rate)
		wav_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
```

## Controls

### Waveform Interaction
- **Left-click**: Seek to position
- **Drag handles**: 
  - **Green handle (top)**: IN point - drag to set loop start
  - **Red handle (bottom)**: OUT point - drag to set loop end
  - **Blue handle (below red)**: REGION - drag to move both points together
- **Right-click**: Set IN point (alternative method)
- **Shift + Right-click**: Set OUT point (alternative method)
- **Handle hover**: Visual feedback when hovering over loop handles

### Transport
- **▶ Play**: Start/pause playback
- **⏹ Stop**: Stop and reset to beginning
- **🔄 Loop**: Toggle loop enable/disable
- **🔄/↔️ Loop Type**: Cycle between Forward and Ping-Pong loop modes
- **+ / Page Up**: Octave up (double pitch/speed)
- **- / Page Down**: Octave down (halve pitch/speed)

### Real-time Controls
- **VOL**: Volume control (-30dB to +6dB)
- **PITCH**: Pitch/speed control (0.000001x to 4.0x) - Extreme range for ultra-detailed audio analysis
- **1/2 button**: Octave down (halve current speed)
- **1x button**: Quick reset to normal speed
- **x2 button**: Octave up (double current speed)
- **Keyboard shortcuts**:
  - **+ / Page Up**: Octave up (double current speed)
  - **- / Page Down**: Octave down (halve current speed)

### File Operations
- **LOAD**: Load WAV audio files

## Enhanced Demo Audio

The demo now features a richer audio sample:
```gdscript
# Create chord progression for better visualization
sample_value += sin(2.0 * PI * 440.0 * t) * 0.3   # A4
sample_value += sin(2.0 * PI * 554.37 * t) * 0.2  # C#5  
sample_value += sin(2.0 * PI * 659.25 * t) * 0.2  # E5

# Add envelope for natural sound
var envelope = sin(PI * t / duration)
sample_value *= envelope * 0.5
```

## Technical Implementation

### Enhanced Handle Interaction
```gdscript
# Improved handle detection with expanded hit areas
func _get_handle_at_position(mouse_pos: Vector2, rect: Rect2) -> String:
	var expanded_size = handle_size + 10.0  # Larger hit area
	
	# Check start handle with expanded bounds
	var start_handle = Rect2(start_x - expanded_size/2, 
							rect.size.y - handle_size - 15, 
							expanded_size, handle_size + 20)
	
	if start_handle.has_point(mouse_pos):
		return "start"
```

### Real-time Drag Feedback
- **Visual indicators**: Handles change color during interaction (green/red → lime/orange → yellow when dragging)
- **Status updates**: Real-time display of current loop point values
- **Constraint handling**: Automatic clamping to valid ranges during drag operations
- **Smooth interaction**: Immediate visual feedback without lag

### Waveform Rendering
- **Peak detection**: Multiple samples per pixel for accurate representation
- **Professional styling**: Dark theme with high contrast colors
- **Grid overlay**: Time-based reference grid for precision
- **Real-time updates**: Smooth playback position tracking

### Loop Point Management
- **Sample-accurate precision**: Loops can be as small as 1 sample
- **Visual separation**: IN point at top, OUT point at bottom, region handle below
- **Region manipulation**: Move entire loop region while maintaining width
- **Smart constraints**: Region movement respects audio boundaries
- **Time-to-sample conversion**: Precise sample-accurate loop points
- **Visual feedback**: Immediate visual confirmation of loop settings
- **Interactive setting**: Click-based loop point manipulation
- **Format compatibility**: Works with all supported WAV formats

## Enhanced Loop Controls

The professional audio player now features intuitive loop controls:

### Loop Controls
- **Loop Toggle** (🔄): Simple on/off switch for looping
  - **Yellow**: Loop is active
  - **No color**: Loop is disabled
- **Loop Type Toggle** (🔄/↔️): Cycles between loop modes
  - **🔄 Forward Loop**: Standard looping from start to end point (default color)
  - **↔️ Ping-Pong Loop**: Alternates between forward and reverse playback (orange color)

### Visual Feedback
- **Separate controls**: Clear distinction between loop enable and loop type
- **Icon-based interface**: Intuitive symbols for each function
- **Color coding**: Different colors indicate active states and loop types
- **Real-time status**: Current loop settings displayed in status bar

## Next Steps

- Try [OGG Vorbis Playback](../ogg_playback/) for compressed audio
- Explore [Positional Audio](../positional_audio/) for spatial sound
- Learn [Audio Mixing](../audio_mixing/) for multiple sources
