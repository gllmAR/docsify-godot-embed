// Docsify plugin for initializing demo iframes
(function() {
  'use strict';
  
  // Simple demo controls setup
  function setupDemoControls(iframeId, fullscreenBtnId, popoutBtnId, demoUrl, sceneName) {
    var iframe = document.getElementById(iframeId);
    var fullscreenBtn = document.getElementById(fullscreenBtnId);
    var popoutBtn = document.getElementById(popoutBtnId);
    
    if (!iframe || !fullscreenBtn || !popoutBtn) return;
    
    // Fullscreen functionality
    fullscreenBtn.addEventListener('click', function() {
      toggleFullscreen(iframe);
    });
    
    // Pop-out functionality  
    popoutBtn.addEventListener('click', function() {
      window.open(demoUrl, `demo-${sceneName}`, 'width=1000,height=800,scrollbars=yes,resizable=yes');
    });
    
    // Listen for fullscreen changes
    document.addEventListener('fullscreenchange', function() {
      updateFullscreenButton(fullscreenBtn);
    });
    document.addEventListener('webkitfullscreenchange', function() {
      updateFullscreenButton(fullscreenBtn);
    });
  }
  
  // Toggle fullscreen for iframe
  function toggleFullscreen(iframe) {
    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else {
      iframe.requestFullscreen().catch(() => {
        // Fallback to pop-out if fullscreen fails
        window.open(iframe.src, '_blank');
      });
    }
  }
  
  // Update fullscreen button text
  function updateFullscreenButton(button) {
    button.textContent = document.fullscreenElement ? '⛶ Exit Fullscreen' : '⛶ Fullscreen';
  }
  
  // State management
  const processedMarkers = new Set();

  function initializeDemoEmbeds() {
    // Find all embed markers (now supports any project name)
    var embedMarkers = document.evaluate(
      '//comment()[contains(., "embed-") and contains(., ":")]',
      document,
      null,
      XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE,
      null
    );
    
    if (embedMarkers.snapshotLength === 0) return;
    
    console.log('Found', embedMarkers.snapshotLength, 'embed markers');
    
    // Get base URL
    var baseUrl = window.location.href.split('#')[0].replace(/\/index\.html$/, '/');
    if (!baseUrl.endsWith('/')) baseUrl += '/';
    
    // Process each marker
    for (let i = 0; i < embedMarkers.snapshotLength; i++) {
      processEmbed(embedMarkers.snapshotItem(i), baseUrl);
    }
  }

  function processEmbed(marker, baseUrl) {
    var markerText = marker.textContent.trim();
    var markerId = markerText + '_' + Date.now();
    
    // Skip if already processed
    if (processedMarkers.has(markerId)) return;
    processedMarkers.add(markerId);
    
    // Check if container already exists
    const nextSibling = marker.nextSibling;
    if (nextSibling && nextSibling.classList && nextSibling.classList.contains('demo-container')) {
      return;
    }
    
    // Parse the marker: <!-- embed-gdEmbed: {$PATH}/tweening_demo --> or <!-- embed-myProject: {$PATH}/scene_name -->
    var embedMatch = markerText.match(/embed-([^:]+):\s*(.+)/);
    if (!embedMatch) {
      console.warn('Invalid embed format:', markerText);
      return;
    }
    
    var projectName = embedMatch[1];  // Extract project name (e.g., "gdEmbed")
    var embedPath = embedMatch[2].trim();
    
    // Handle path expansion for {$PATH} substitution
    if (embedPath.startsWith('{$PATH}/')) {
      // Get current document path from URL hash
      var currentHash = window.location.hash.substring(1); // Remove #
      var currentPath = '';
      
      if (currentHash) {
        // Extract directory path from current route
        // E.g., from "#/gdEmbed/scenes/animation/tweening/README" get "scenes/animation/tweening"
        var pathPattern = new RegExp(`${projectName}\\/(scenes\\/[^\\/]+\\/[^\\/]+)`);
        var pathMatch = currentHash.match(pathPattern);
        if (pathMatch) {
          currentPath = pathMatch[1];
        }
      }
      
      if (!currentPath) {
        console.warn('Could not determine current path for {$PATH} expansion');
        return;
      }
      
      // Replace {$PATH} with the current path
      embedPath = embedPath.replace('{$PATH}', currentPath);
      console.log(`Path expansion: {$PATH} -> ${currentPath}, final path: ${embedPath}`);
    }
    
    var pathParts = embedPath.split('/');
    
    if (pathParts.length < 4) {
      console.warn('Invalid embed path format:', embedPath);
      return;
    }
    
    // Extract path components: scenes/animation/tweening/tweening
    var category = pathParts[1];        // animation
    var sceneFolder = pathParts[2];     // tweening  
    var sceneName = pathParts[3];       // tweening (actual scene name)
    
    // Pass the full scene path to Godot
    var fullScenePath = `${category}/${sceneFolder}`;
    
    // Build demo URL using the project name and pass the full scene path
    var demoPath = `${projectName}/exports/web/?scene=${encodeURIComponent(fullScenePath)}`;
    var fullDemoUrl = baseUrl + demoPath;
    
    console.log(`Embedding: ${sceneName} (full path: ${fullScenePath}, project: ${projectName}) -> ${fullDemoUrl}`);
    
    // Create container
    var container = document.createElement('div');
    container.className = 'demo-container';
    
    var iframeId = `demo-iframe-${sceneName}-${Date.now()}`;
    var fullscreenBtnId = `fullscreen-btn-${sceneName}-${Date.now()}`;
    var popoutBtnId = `popout-btn-${sceneName}-${Date.now()}`;

    container.innerHTML = `
      <div class="demo-header">
        <h3>🎮 Interactive Demo: ${sceneName}</h3>
        <div class="demo-controls">
          <button id="${fullscreenBtnId}" class="btn-fullscreen">⛶ Fullscreen</button>
          <button id="${popoutBtnId}" class="btn-popout">↗ Pop Out</button>
        </div>
      </div>
      <div class="iframe-wrapper">
        <iframe 
          id="${iframeId}" 
          src="${fullDemoUrl}"
          width="800" 
          height="600" 
          frameborder="0"
          allowfullscreen="true">
          <p>Your browser does not support iframes. <a href="${fullDemoUrl}" target="_blank">Open demo in new tab</a></p>
        </iframe>
      </div>
      <p class="demo-instructions">Use arrow keys to move • Press R to reset • Interactive demo</p>
    `;
    
    // Insert container after marker
    marker.parentNode.insertBefore(container, marker.nextSibling);
    
    // Setup controls
    setTimeout(() => {
      setupDemoControls(iframeId, fullscreenBtnId, popoutBtnId, fullDemoUrl, sceneName);
    }, 100);
  }
  
  // Plugin initialization
  function initializePlugin() {
    // Clear processed markers on route change
    processedMarkers.clear();
    
    // Initialize embeds after DOM is ready
    setTimeout(initializeDemoEmbeds, 100);
  }
  
  // Register Docsify plugin
  window.$docsify = window.$docsify || {};
  window.$docsify.plugins = (window.$docsify.plugins || []).concat(function(hook) {
    hook.doneEach(initializePlugin);
  });
  
  // Monitor hash changes for SPA navigation
  window.addEventListener('hashchange', () => {
    setTimeout(initializePlugin, 200);
  });
  
  console.log('🎮 Demo embed plugin loaded');
})();
