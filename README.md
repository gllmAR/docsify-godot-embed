# docsify-godot-embed

A Docsify plugin to embed Godot projects and scenes in iframes with interactive controls.

<!-- embed-gdEmbed -->



## Features

- 🎮 **Project Embedding**: Embed entire Godot projects with scene browsers
- 🎯 **Scene-Specific Embedding**: Embed specific scenes directly
- 🔄 **Dynamic Path Resolution**: Support for path variables and current directory resolution
- 📱 **Responsive Design**: Adaptive UI that works on desktop and mobile
- ⛶ **Fullscreen Support**: Full-screen viewing with controls
- ↗️ **Pop-out Windows**: Open demos in separate windows
- 🌐 **Cross-Origin Ready**: Proper headers for iframe embedding

## Usage

### Basic Project Embed

Embed the entire project with scene browser:

```html
<!-- embed-gdEmbed -->
```

This creates a full project browser where users can explore all available scenes.

### Specific Scene Embed

Embed a specific scene:

```html
<!-- embed-gdEmbed: audio/advance_audioplayer -->
```

Available scene paths:
- `animation/basic_animation` - Basic animation example
- `animation/state_machines` - Animation state machines
- `animation/tweening` - Tweening animations
- `audio/advance_audioplayer` - Advanced audio player
- `audio/basic_audio` - Basic audio demo
- `input/gamepad_input` - Gamepad input handling
- `input/keyboard_input` - Keyboard input demo
- `input/mouse_input` - Mouse input example
- `movement/basic_movement` - Basic character movement
- `movement/platformer_movement` - Platformer movement mechanics
- `movement/top_down_movement` - Top-down movement
- `physics/basic_physics` - Basic physics demo
- `physics/collision_detection` - Collision detection
- `physics/rigid_bodies` - Rigid body physics
- `visual_effects/particle_systems` - Particle systems
- `visual_effects/shader_effects` - Shader effects

### Dynamic Path Resolution

Use current path for relative scene embedding:

```html
<!-- embed-gdEmbed: {$PATH}/demo_scene -->
```
This uses the current page's path to determine which scene to embed. Useful for documentation that follows the same structure as your scenes.

## How It Works

1. The plugin scans for HTML comments with the `embed-` prefix
2. Extracts the project name and optional scene path
3. Generates iframe URLs pointing to your Godot web exports
4. Creates interactive containers with fullscreen and pop-out controls
5. Applies responsive styling for optimal viewing

## Project Structure

Your Godot project should be structured like this:

```
projectName/
├── exports/
│   └── web/
│       ├── index.html
│       ├── index.js
│       ├── index.pck
│       └── index.wasm
└── scenes/
    ├── category1/
    │   └── scene1/
    └── category2/
        └── scene2/
```

## Integration with Dynamic Scene Browser

This plugin works seamlessly with the Dynamic Scene Browser addon:

- **Manifest-Based Discovery**: Fast scene loading from pre-generated manifests
- **URL Parameter Support**: Direct scene access via `?scene=path` parameters
- **Hierarchical Navigation**: Organized scene browsing when no specific scene is requested
- **Web Export Integration**: Automatic manifest generation during builds

## Examples

### Documentation Page

```markdown
# Animation Examples

Learn about Godot animations with these interactive demos:

## Project Overview
<!-- embed-gdEmbed -->

## Basic Animation
<!-- embed-gdEmbed: scenes/animation/basic_animation/basic_animation -->

## Advanced Tweening
<!-- embed-gdEmbed: scenes/animation/tweening/tweening -->
```

### Context-Aware Embedding

```markdown
# Current Section Demo

This demo shows the concepts from this section:

<!-- embed-gdEmbed: {$PATH}/section_demo -->
```

## Styling

The plugin includes responsive CSS that adapts to different screen sizes:

- **Desktop**: Full-sized demos with controls
- **Tablet**: Optimized dimensions for touch interfaces  
- **Mobile**: Compact view with accessible controls
- **Dark Mode**: Automatic dark theme support

## Configuration

The plugin works out-of-the-box but can be customized via the Godot project settings:

```gdscript
# Project Settings
dynamic_scene_browser/base_path = "res://scenes/"
dynamic_scene_browser/auto_generate_manifests = true
dynamic_scene_browser/show_browser_on_empty_scene = true
```

## Browser Compatibility

- Modern browsers with iframe support
- JavaScript enabled for interactive controls
- WebAssembly support for Godot web exports
- Cross-origin iframe embedding capabilities

