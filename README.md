# docsify-godot-embed

A comprehensive Docsify plugin to embed Godot projects and scenes in iframes with interactive controls, responsive design, and cross-platform compatibility.

<!-- embed-gdEmbed -->

## Quick Start

### Installation

1. **Include the plugin in your Docsify HTML:**

```html
<!-- CSS for styling -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/gllmAR/docsify-godot-embed@main/docsify-embed-godot.css">

<!-- JavaScript plugin -->
<script src="https://cdn.jsdelivr.net/gh/gllmAR/docsify-godot-embed@main/docsify-embed-godot.js"></script>
```

2. **Add embed markers to your Markdown:**

```markdown
<!-- For project browser -->
<!-- embed-gdEmbed -->

<!-- For specific scenes -->
<!-- embed-gdEmbed: audio/advance_audioplayer -->

<!-- For path-based embedding -->
<!-- embed-{$PATH} -->
```

3. **Ensure your Godot project structure follows the convention:**

```
projectName/
├── exports/web/          # Web export files
└── scenes/              # Scene organization
    ├── category/
    └── scene_name/
```

## Features

- 🎮 **Project Embedding**: Embed entire Godot projects with scene browsers
- 🎯 **Scene-Specific Embedding**: Embed specific scenes directly
- 🔄 **Dynamic Path Resolution**: Support for path variables and current directory resolution
- 📱 **Responsive Design**: Adaptive UI that works on desktop and mobile
- ⛶ **Fullscreen Support**: Multiple fullscreen modes for different devices
- ↗️ **Pop-out Windows**: Open demos in separate windows or tabs
- 🌐 **Cross-Origin Ready**: Proper headers for iframe embedding
- 📱 **Mobile Optimized**: Touch gestures and mobile-specific controls

## Embed Formats

### 1. Project Browser Embed
Embeds the entire project with interactive scene selection:

```html
<!-- embed-gdEmbed -->
```

### 2. Specific Scene Embed
Embeds a particular scene directly:

```html
<!-- embed-gdEmbed: audio/advance_audioplayer -->
```

### 3. Path-Based Embed
Uses current page path to determine scene:

```html
<!-- embed-{$PATH} -->
```

This automatically resolves to the appropriate scene based on the current documentation path.

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
- `midi/comprehensive_midi_demo` - Complete MIDI demo with device selection and sampler
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

## Advanced Configuration

### Custom Base Paths

```javascript
// In your Docsify configuration
window.$docsify = {
  // ...existing config...
  
  // Custom embed settings (optional)
  embedGodot: {
    basePath: 'custom/path/to/exports/',
    defaultProject: 'myProject',
    mobileOptimizations: true
  }
};
```

### Multiple Projects

Support for multiple Godot projects in one documentation site:

```html
<!-- Different projects -->
<!-- embed-project1 -->
<!-- embed-project2: scenes/demo/example -->
```

## Browser Compatibility

| Feature | Chrome | Firefox | Edge | Safari | Mobile |
|---------|--------|---------|------|--------|---------|
| Basic Embed | ✅ | ✅ | ✅ | ✅ | ✅ |
| Fullscreen | ✅ | ✅ | ✅ | ⚠️ | ✅ |
| Pop-out | ✅ | ✅ | ✅ | ✅ | ✅ |
| Touch Controls | ✅ | ✅ | ✅ | ✅ | ✅ |

## Examples Repository

The `gdEmbed` folder contains a complete example project with:

- **17+ Interactive Demos**: Animation, Audio, Physics, Input, MIDI, Movement, Visual Effects
- **Professional UI**: Consistent styling and responsive design
- **Educational Content**: Step-by-step tutorials and code examples
- **Best Practices**: Real-world implementation patterns

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Test with the example project
4. Commit your changes (`git commit -m 'Add AmazingFeature'`)
5. Push to the branch (`git push origin feature/AmazingFeature`)
6. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📖 [Documentation](https://gllmar.github.io/docsify-godot-embed/)
- 🐛 [Issue Tracker](https://github.com/gllmAR/docsify-godot-embed/issues)
- 💬 [Discussions](https://github.com/gllmAR/docsify-godot-embed/discussions)

