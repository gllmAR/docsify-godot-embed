# Getting Started

This guide will help you integrate the docsify-godot-embed plugin into your Docsify documentation site.

## Prerequisites

- Docsify site (v4.0+ recommended)
- Godot project with web export
- Basic understanding of HTML/CSS
- Web server for hosting (for testing)

## Installation

### Method 1: CDN (Recommended)

Add these lines to your `index.html`:

```html
<!-- In the <head> section -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/gllmAR/docsify-godot-embed@main/docsify-embed-godot.css">

<!-- Before closing </body> tag, after other Docsify scripts -->
<script src="https://cdn.jsdelivr.net/gh/gllmAR/docsify-godot-embed@main/docsify-embed-godot.js"></script>
```

### Method 2: Local Installation

1. Download the plugin files:
   - `docsify-embed-godot.js`
   - `docsify-embed-godot.css`

2. Place them in your project directory

3. Reference them in your HTML:

```html
<link rel="stylesheet" href="./docsify-embed-godot.css">
<script src="./docsify-embed-godot.js"></script>
```

## Project Structure

Organize your Godot project for embedding:

```
your-docs/
├── index.html           # Docsify entry point
├── README.md           # Main documentation
├── myProject/          # Your Godot project
│   ├── exports/
│   │   └── web/        # Web export files
│   │       ├── index.html
│   │       ├── index.js
│   │       ├── index.pck
│   │       └── index.wasm
│   └── scenes/         # Scene organization (optional)
│       ├── category1/
│       └── category2/
└── docs/              # Additional documentation
```

## Basic Usage

### 1. Project Embed

Embed your entire project with scene browser:

```markdown
# My Game Documentation

Here's an interactive demo of my game:

<!-- embed-myProject -->

The project includes multiple scenes you can explore.
```

### 2. Scene-Specific Embed

Embed a specific scene directly:

```markdown
# Audio System Tutorial

Try the advanced audio player:

<!-- embed-myProject: audio/advance_audioplayer -->

This demonstrates spatial audio positioning.
```

### 3. Path-Based Embed

Let the plugin automatically resolve the scene based on current path:

```markdown
# Current Demo

<!-- embed-{$PATH} -->

This will embed the scene that corresponds to the current page path.
```

## Godot Project Setup

### Web Export Settings

1. In Godot, go to **Project → Export**
2. Add **Web** export preset
3. Configure these settings:
   - **Export Path**: `exports/web/index.html`
   - **Custom HTML Shell**: Use default or custom
   - **Head Include**: Add any custom meta tags

### Headers for Embedding

For iframe embedding, ensure your web server sends proper headers:

```
Cross-Origin-Embedder-Policy: require-corp
Cross-Origin-Opener-Policy: same-origin
```

Many hosting platforms handle this automatically for static sites.

## Testing Your Setup

1. **Start a local server** (required for web exports):
   ```bash
   # Using Python
   python -m http.server 8000
   
   # Using Node.js
   npx serve .
   
   # Using PHP
   php -S localhost:8000
   ```

2. **Visit your Docsify site**: `http://localhost:8000`

3. **Verify the embed appears** with proper controls

## Troubleshooting

### Common Issues

**Embed doesn't appear:**
- Check browser console for errors
- Verify file paths are correct
- Ensure web server is running

**Iframe is blank:**
- Check Godot export completed successfully
- Verify Cross-Origin headers
- Test the Godot export directly

**Controls not working:**
- Ensure CSS file is loaded
- Check for JavaScript errors
- Verify plugin loaded after Docsify

### Debug Mode

Enable verbose logging:

```javascript
// Add to your Docsify config
window.$docsify = {
  // ...existing config...
  
  plugins: [
    // ...existing plugins...
    function(hook) {
      // Enable debug logging
      window.docsifyGodotDebug = true;
    }
  ]
};
```

## Next Steps

- Learn about [Advanced Usage](advanced.md) patterns
- Customize appearance with [Styling Guide](styling.md)
- Optimize for mobile with [Mobile Support](mobile.md)
- Explore more [Examples](examples.md)
