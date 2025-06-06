// Docsify plugin for initializing demo iframes
(function() {
  'use strict';
  
  // Toggle fullscreen for iframe with mobile support
  function toggleFullscreen(iframe) {
    if (document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement) {
      // Exit fullscreen
      if (document.exitFullscreen) {
        document.exitFullscreen();
      } else if (document.webkitExitFullscreen) {
        document.webkitExitFullscreen();
      } else if (document.mozCancelFullScreen) {
        document.mozCancelFullScreen();
      }
    } else {
      // Enter fullscreen with mobile fallbacks
      if (isMobileDevice()) {
        handleMobileFullscreen(iframe);
      } else {
        // Desktop fullscreen
        if (iframe.requestFullscreen) {
          iframe.requestFullscreen().catch(() => handleMobileFullscreen(iframe));
        } else if (iframe.webkitRequestFullscreen) {
          iframe.webkitRequestFullscreen();
        } else if (iframe.mozRequestFullScreen) {
          iframe.mozRequestFullScreen();
        } else {
          handleMobileFullscreen(iframe);
        }
      }
    }
  }

  function isMobileDevice() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) || 
           ('ontouchstart' in window) || 
           (window.innerWidth <= 768);
  }

  function handleMobileFullscreen(iframe) {
    // Mobile fullscreen fallback
    var container = iframe.closest('.demo-container');
    
    if (container.classList.contains('mobile-fullscreen')) {
      // Exit mobile fullscreen
      exitMobileFullscreen(container);
    } else {
      // Enter mobile fullscreen
      enterMobileFullscreen(container);
    }
  }

  function enterMobileFullscreen(container) {
    container.classList.add('mobile-fullscreen');
    document.body.classList.add('mobile-fullscreen-active');
    
    // Lock scroll
    document.body.style.overflow = 'hidden';
    
    // Try to hide address bar on mobile
    if (window.screen && window.screen.orientation) {
      // Modern mobile browsers
      setTimeout(() => {
        window.scrollTo(0, 1);
      }, 100);
    }
    
    // Update button text
    var fullscreenBtn = container.querySelector('.btn-fullscreen');
    if (fullscreenBtn) {
      fullscreenBtn.textContent = '⛶ Exit Fullscreen';
    }
  }

  function exitMobileFullscreen(container) {
    container.classList.remove('mobile-fullscreen');
    document.body.classList.remove('mobile-fullscreen-active');
    
    // Restore scroll
    document.body.style.overflow = '';
    
    // Update button text
    var fullscreenBtn = container.querySelector('.btn-fullscreen');
    if (fullscreenBtn) {
      fullscreenBtn.textContent = '⛶ Fullscreen';
    }
  }

  // Update fullscreen button text with mobile support
  function updateFullscreenButton(button) {
    var isFullscreen = document.fullscreenElement || 
                      document.webkitFullscreenElement || 
                      document.mozFullScreenElement ||
                      button.closest('.demo-container').classList.contains('mobile-fullscreen');
    
    button.textContent = isFullscreen ? '⛶ Exit Fullscreen' : '⛶ Fullscreen';
  }
  
  // Simple demo controls setup with mobile enhancements
  function setupDemoControls(iframeId, fullscreenBtnId, popoutBtnId, demoUrl, sceneName) {
    var iframe = document.getElementById(iframeId);
    var fullscreenBtn = document.getElementById(fullscreenBtnId);
    var popoutBtn = document.getElementById(popoutBtnId);
    
    if (!iframe || !fullscreenBtn || !popoutBtn) return;
    
    // Fullscreen functionality with mobile support
    fullscreenBtn.addEventListener('click', function() {
      toggleFullscreen(iframe);
    });
    
    // Pop-out functionality with mobile adjustments
    popoutBtn.addEventListener('click', function() {
      if (isMobileDevice()) {
        // On mobile, open in same tab to avoid popup blockers
        window.open(demoUrl, '_blank');
      } else {
        window.open(demoUrl, `demo-${sceneName}`, 'width=1000,height=800,scrollbars=yes,resizable=yes');
      }
    });
    
    // Listen for fullscreen changes (all vendors)
    document.addEventListener('fullscreenchange', function() {
      updateFullscreenButton(fullscreenBtn);
    });
    document.addEventListener('webkitfullscreenchange', function() {
      updateFullscreenButton(fullscreenBtn);
    });
    document.addEventListener('mozfullscreenchange', function() {
      updateFullscreenButton(fullscreenBtn);
    });
    
    // Listen for escape key to exit mobile fullscreen
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        var container = iframe.closest('.demo-container');
        if (container && container.classList.contains('mobile-fullscreen')) {
          exitMobileFullscreen(container);
        }
      }
    });
    
    // Add touch gesture support for mobile fullscreen
    if (isMobileDevice()) {
      addMobileTouchSupport(iframe);
    }
  }

  function addMobileTouchSupport(iframe) {
    var doubleTapTimeout;
    var lastTap = 0;
    
    iframe.addEventListener('touchend', function(e) {
      var currentTime = new Date().getTime();
      var tapLength = currentTime - lastTap;
      
      if (tapLength < 500 && tapLength > 0) {
        // Double tap detected
        e.preventDefault();
        toggleFullscreen(iframe);
      }
      
      lastTap = currentTime;
    });
  }

  // State management
  const processedMarkers = new Set();

  function initializeDemoEmbeds() {
    // Find all embed markers
    var embedMarkers = document.evaluate(
      '//comment()[contains(., "embed-")]',
      document,
      null,
      XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE,
      null
    );
    
    if (embedMarkers.snapshotLength === 0) {
      return;
    }
    
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
    if (processedMarkers.has(markerId)) {
      return;
    }
    processedMarkers.add(markerId);
    
    // Check if container already exists
    const nextSibling = marker.nextSibling;
    if (nextSibling && nextSibling.classList && nextSibling.classList.contains('demo-container')) {
      return;
    }
    
    // Parse the marker
    var embedMatch = markerText.match(/embed-([a-zA-Z0-9_-]+)(?:\s*:\s*(.+))?/);
    if (!embedMatch) {
      console.warn('Invalid embed format:', markerText);
      return;
    }
    
    var projectName = embedMatch[1];
    var embedPath = embedMatch[2];
    
    var sceneName, fullScenePath, demoPath;
    
    if (!embedPath) {
      // Simple embed format: <!-- embed-projectName -->
      sceneName = `${projectName} Project`;
      fullScenePath = '';
      demoPath = `${projectName}/exports/web/`;
    } else {
      // Full embed format with specific scene path
      embedPath = embedPath.trim();
      
      // Handle path expansion for {$PATH} substitution
      if (embedPath.startsWith('{$PATH}/')) {
        var currentHash = window.location.hash.substring(1);
        var currentPath = '';
        
        if (currentHash) {
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
        
        embedPath = embedPath.replace('{$PATH}', currentPath);
      }
      
      var pathParts = embedPath.split('/');
      
      if (pathParts.length < 4) {
        console.warn('Invalid embed path format:', embedPath);
        return;
      }
      
      var category = pathParts[1];
      var sceneFolder = pathParts[2];
      sceneName = pathParts[3];
      
      var scenePath = `${category}/${sceneFolder}`;
      demoPath = `${projectName}/exports/web/?scene=${encodeURIComponent(scenePath)}`;
    }
    
    // Build demo URL
    var fullDemoUrl = baseUrl + demoPath;
    
    // Create container
    var container = document.createElement('div');
    container.className = 'demo-container';
    
    if (!embedPath) {
      container.classList.add('demo-project-embed');
    }
    
    var iframeId = `demo-iframe-${sceneName.replace(/\s+/g, '-')}-${Date.now()}`;
    var fullscreenBtnId = `fullscreen-btn-${sceneName.replace(/\s+/g, '-')}-${Date.now()}`;
    var popoutBtnId = `popout-btn-${sceneName.replace(/\s+/g, '-')}-${Date.now()}`;

    var headerTitle = embedPath ? 
      `🎮 Interactive Demo: ${sceneName}` : 
      `🎮 ${sceneName}`;
    
    var instructions = embedPath ?
      'Use arrow keys to move • Press R to reset • Interactive demo' :
      'Browse and select scenes • Interactive project explorer';

    container.innerHTML = `
      <div class="demo-header">
        <h3>${headerTitle}</h3>
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
      <p class="demo-instructions">${instructions}</p>
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
