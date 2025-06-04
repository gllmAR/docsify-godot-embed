# CI/CD Usage Guide

## Multi-Project Godot Build System

This repository supports building multiple Godot projects automatically through GitHub Actions.

## Default Behavior

By default, the CI builds the following projects:
- `gdEmbed`

## Manual Trigger with Custom Projects

You can manually trigger the workflow and specify which projects to build:

1. Go to **Actions** tab in your GitHub repository
2. Click on **Deploy Docsify with Godot Demos to GitHub Pages**
3. Click **Run workflow**
4. In the **Godot projects** field, enter a comma-separated list of project folders

### Examples:

**Single project:**
```
gdEmbed
```

**Multiple projects:**
```
gdEmbed,myOtherGame,experimentalDemo
```

**With spaces (will be trimmed):**
```
gdEmbed, myOtherGame, experimentalDemo
```

## Project Requirements

For a project to be built by the CI, it must:

1. **Have a `Makefile`** with the following targets:
   - `check-godot` - Verify Godot installation
   - `check-preset` - Verify export preset configuration  
   - `status` - Show build status
   - `ci-build` - Clean rebuild for deployment

2. **Have a `project.godot`** file (Godot project file)

3. **Have an `export_presets.cfg`** with a "Web" preset configured

4. **Export to `exports/web/`** directory with these files:
   - `index.html` - Main HTML file
   - `index.wasm` - WebAssembly binary (tracked by Git LFS)
   - `index.pck` - Game data (tracked by Git LFS)  
   - `index.js` - JavaScript loader

## Adding New Godot Projects

To add a new Godot project to the repository:

1. **Create project directory:**
   ```bash
   mkdir myNewGame
   cd myNewGame
   ```

2. **Copy the Makefile from gdEmbed:**
   ```bash
   cp ../gdEmbed/Makefile .
   ```

3. **Set up your Godot project** with export presets

4. **Test the build locally:**
   ```bash
   make check-godot
   make check-preset
   make ci-build
   ```

5. **Add to Git** (project files only - WASM/PCK files are built on CI):
   ```bash
   # Only add the project source files - CI will build WASM/PCK files
   git add yourprojectname/
   git commit -m "Add new Godot project for CI building"
   ```

   **Note**: WASM and PCK files are automatically built on the CI server and are excluded from Git tracking via `.gitignore` for faster repository operations.

6. **Update default projects** (optional):
   Edit the `DEFAULT_GODOT_PROJECTS` environment variable in `.github/workflows/deploy.yml`

## Deployment URLs

After successful deployment, your projects will be available at:
- Main site: `https://yourusername.github.io/yourrepo/`
- Project demos: `https://yourusername.github.io/yourrepo/projectname/exports/web/`

For example:
- `https://yourusername.github.io/docsify-godot-embed/gdEmbed/exports/web/`

## Troubleshooting

### Project Skipped
If you see "No Makefile found" or "No project.godot found", ensure:
- The project directory exists
- The Makefile is present and has the required targets
- The project.godot file exists

### Build Failures
Check the Actions logs for:
- Export preset configuration issues
- Missing export templates
- File size validation failures
- Git LFS tracking problems

### Large Artifact Size
The CI automatically cleans up:
- Downloaded Godot engine (~100MB)
- Export templates (~1.2GB)
- Temporary build files

Only the final export files are included in the deployment artifact.

## Example Workflow

```yaml
# Manual trigger example
on:
  workflow_dispatch:
    inputs:
      godot_projects:
        description: 'Comma-separated list of Godot project folders to build'
        required: false
        default: 'gdEmbed,newProject,experimental'
        type: string
```

This allows you to build any combination of projects on demand!
