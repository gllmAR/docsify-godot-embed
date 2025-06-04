// Docsify plugin for initializing demo iframes
(function() {
  'use strict';
  
  // Enhanced demo controls setup
  function setupDemoControls(iframeId, fullscreenBtnId, popoutBtnId, demoUrl, sceneName) {
    var iframe = document.getElementById(iframeId);
    var fullscreenBtn = document.getElementById(fullscreenBtnId);
    var popoutBtn = document.getElementById(popoutBtnId);
    
    if (!iframe || !fullscreenBtn || !popoutBtn) {
      console.warn('Demo controls setup failed - elements not found');
      return;
    }
    
    // Fullscreen functionality
    fullscreenBtn.addEventListener('click', function() {
      toggleFullscreen(iframe, fullscreenBtn);
    });
    
    // Pop-out functionality  
    popoutBtn.addEventListener('click', function() {
      openPopout(demoUrl, sceneName);
    });
    
    // Listen for fullscreen changes to update button text
    document.addEventListener('fullscreenchange', function() {
      updateFullscreenButton(fullscreenBtn);
    });
    document.addEventListener('webkitfullscreenchange', function() {
      updateFullscreenButton(fullscreenBtn);
    });
    document.addEventListener('mozfullscreenchange', function() {
      updateFullscreenButton(fullscreenBtn);
    });
    
    // Responsive iframe sizing
    setupResponsiveResize(iframe);
  }
  
  // Toggle fullscreen for iframe
  function toggleFullscreen(iframe, button) {
    try {
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
        // Enter fullscreen
        if (iframe.requestFullscreen) {
          iframe.requestFullscreen();
        } else if (iframe.webkitRequestFullscreen) {
          iframe.webkitRequestFullscreen();
        } else if (iframe.mozRequestFullScreen) {
          iframe.mozRequestFullScreen();
        } else {
          // Fallback: open in new window if fullscreen not supported
          console.log('Fullscreen not supported, opening pop-out');
          openPopout(iframe.src, 'demo');
        }
      }
    } catch (error) {
      console.warn('Fullscreen failed:', error);
      // Fallback to pop-out
      openPopout(iframe.src, 'demo');
    }
  }
  
  // Update fullscreen button text
  function updateFullscreenButton(button) {
    if (document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement) {
      button.textContent = '⛶ Exit Fullscreen';
      button.title = 'Exit fullscreen';
    } else {
      button.textContent = '⛶ Fullscreen';
      button.title = 'Toggle fullscreen';
    }
  }
  
  // Open demo in pop-out window
  function openPopout(url, sceneName) {
    var popoutWindow = window.open(
      url,
      `demo-${sceneName}-${Date.now()}`,
      'width=1000,height=800,scrollbars=yes,resizable=yes,toolbar=no,menubar=no,location=no,status=no'
    );
    
    if (popoutWindow) {
      popoutWindow.focus();
      console.log('Demo opened in pop-out window');
    } else {
      console.warn('Pop-up blocked or failed');
      // Fallback: open in new tab
      window.open(url, '_blank');
    }
  }
  
  // Setup responsive iframe resizing with performance optimization
  function setupResponsiveResize(iframe) {
    let resizeTimeout;
    
    function resizeIframe() {
      var container = iframe.closest('.iframe-wrapper');
      if (container) {
        var containerWidth = container.offsetWidth;
        var aspectRatio = 4/3; // Default 4:3 ratio
        var newHeight = containerWidth / aspectRatio;
        
        // Ensure minimum and maximum heights
        newHeight = Math.max(300, Math.min(newHeight, 800));
        
        // Only update if size changed significantly (avoid micro-adjustments)
        const currentHeight = parseInt(iframe.style.height) || 0;
        if (Math.abs(newHeight - currentHeight) > 5) {
          iframe.style.height = newHeight + 'px';
          console.log(`Resized iframe: ${containerWidth}x${newHeight}`);
        }
      }
    }
    
    // Initial resize
    setTimeout(resizeIframe, 100);
    
    // Throttled resize on window resize (60fps max)
    window.addEventListener('resize', () => {
      clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(resizeIframe, 16);
    });
    
    // Resize when iframe loads (for content-based sizing)
    iframe.addEventListener('load', function() {
      setTimeout(resizeIframe, 200);
    });
  }
  
  function initializeDemoEmbeds() {
    console.log('🚀 Demo embed plugin initializing...');
    
    // Find all embed markers in the content
    var embedMarkers = document.evaluate(
      '//comment()[contains(., "start-embed-")]',
      document,
      null,
      XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE,
      null
    );
    
    if (embedMarkers.snapshotLength === 0) {
      console.log('No embed markers found on this page');
      return;
    }
    
    console.log('Found', embedMarkers.snapshotLength, 'embed markers');
    
    // Get base URL (everything before the #)
    var currentUrl = window.location.href;
    var baseUrl = currentUrl.split('#')[0];
    
    // Fix for local development: remove index.html from base URL
    // This prevents URLs like: http://127.0.0.1:5501/index.html/gdEmbed/exports/web/
    // And ensures they become: http://127.0.0.1:5501/gdEmbed/exports/web/
    baseUrl = baseUrl.replace(/\/index\.html$/, '/');
    
    // Ensure base URL ends with a slash
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }
    
    // Process each embed marker
    for (var i = 0; i < embedMarkers.snapshotLength; i++) {
      var marker = embedMarkers.snapshotItem(i);
      var markerText = marker.textContent.trim();
      
      console.log('Processing marker:', markerText);
      
      // Parse the marker: <!-- start-embed-TYPE-/path/to/export?params -->
      var embedMatch = markerText.match(/start-embed-([a-zA-Z0-9-]+)-(.+)/);
      if (!embedMatch) {
        console.warn('Invalid embed marker format:', markerText);
        continue;
      }
      
      var embedType = embedMatch[1];
      var embedPath = embedMatch[2];
      var sceneName = '';
      
      // Fix for remote deployment: remove index.html from path to use directory URL
      // This fixes the issue where ?scene= parameters don't work with explicit index.html
      embedPath = embedPath.replace(/\/index\.html(\?|$)/, '/$1');
      
      // Extract scene name from path (look for ?scene=NAME)
      var sceneMatch = embedPath.match(/[?&]scene=([^&]+)/);
      if (sceneMatch) {
        sceneName = sceneMatch[1];
      } else {
        // Fallback: extract from path
        var pathParts = embedPath.split('/');
        sceneName = pathParts[pathParts.length - 1].replace('.html', '');
      }
      
      var fullDemoUrl = baseUrl + embedPath;
      
      // Fix double slash issue in URL construction
      fullDemoUrl = fullDemoUrl.replace(/([^:]\/)\/+/g, '$1');
      
      console.log(`🔍 URL Construction Debug:`);
      console.log(`  Current URL: ${currentUrl}`);
      console.log(`  Base URL: ${baseUrl}`);
      console.log(`  Embed Path: ${embedPath}`);
      console.log(`  Final URL: ${fullDemoUrl}`);
      console.log(`✅ Embedding: ${sceneName} -> ${fullDemoUrl}`);
      
      // Create the iframe container with enhanced resolution awareness
      var container = document.createElement('div');
      container.className = 'demo-container';
      container.style.cssText = `
        text-align: center; 
        margin: 20px 0; 
        position: relative;
        max-width: 100%;
      `;
      
      // Create unique IDs for this demo
      var iframeId = `demo-iframe-${sceneName}-${Date.now()}`;
      var fullscreenBtnId = `fullscreen-btn-${sceneName}-${Date.now()}`;
      var popoutBtnId = `popout-btn-${sceneName}-${Date.now()}`;
      
      container.innerHTML = `
        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px; flex-wrap: wrap;">
          <h3 style="margin: 0; flex: 1;">🎮 Interactive Demo: ${sceneName}</h3>
          <div style="display: flex; gap: 10px; align-items: center;">
            <button id="${fullscreenBtnId}" 
                    style="padding: 8px 12px; background: #007acc; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 12px;"
                    title="Toggle fullscreen">
              ⛶ Fullscreen
            </button>
            <button id="${popoutBtnId}" 
                    style="padding: 8px 12px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 12px;"
                    title="Open in new window">
              ↗ Pop Out
            </button>
          </div>
        </div>
        <div class="iframe-wrapper" style="position: relative; width: 100%; max-width: 900px; margin: 0 auto;">
          <iframe 
            id="${iframeId}" 
            src="${fullDemoUrl}"
            width="800" 
            height="600" 
            frameborder="0"
            allowfullscreen="true"
            webkitallowfullscreen="true"
            mozallowfullscreen="true"
            onload="console.log('✅ Demo loaded:', '${sceneName}')"
            onerror="console.error('❌ Failed to load demo:', '${sceneName}', '${fullDemoUrl}')"
            style="
              border: 2px solid #ddd; 
              border-radius: 8px; 
              width: 100%; 
              height: auto; 
              min-height: 400px;
              aspect-ratio: 4/3;
              display: block;
              background: #000;
            ">
            <p>Your browser does not support iframes. <a href="${fullDemoUrl}" target="_blank">Open demo in new tab</a></p>
          </iframe>
        </div>
        <p style="font-size: 0.9em; color: #666; margin-top: 10px;">
          Use arrow keys to move • Press R to reset • Interactive tutorial demo
        </p>
      `;
      
      // Insert the container after the marker
      marker.parentNode.insertBefore(container, marker.nextSibling);
      
      // Add event listeners for enhanced functionality
      setupDemoControls(iframeId, fullscreenBtnId, popoutBtnId, fullDemoUrl, sceneName);
      
      console.log('  ✅ Enhanced iframe injected for:', sceneName);
    }
  }
  
  // Docsify plugin
  window.$docsify = window.$docsify || {};
  window.$docsify.plugins = (window.$docsify.plugins || []).concat(function(hook) {
    hook.doneEach(function() {
      // Wait a bit for DOM to be fully ready
      setTimeout(initializeDemoEmbeds, 100);
    });
  });
  
  console.log('🎮 Demo embed plugin loaded');
})();
