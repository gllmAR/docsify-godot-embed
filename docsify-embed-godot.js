// Docsify plugin for initializing demo iframes
(function() {
  'use strict';
  
  // Enhanced demo controls setup
  function setupDemoControls(iframeId, fullscreenBtnId, popoutBtnId, demoUrl, sceneName, placeholderElement) {
    var iframe = document.getElementById(iframeId);
    var fullscreenBtn = document.getElementById(fullscreenBtnId);
    var popoutBtn = document.getElementById(popoutBtnId);
    
    if (!iframe || !fullscreenBtn || !popoutBtn) {
      console.warn('Demo controls setup failed - elements not found');
      return;
    }
    
    // Fullscreen functionality
    fullscreenBtn.addEventListener('click', function() {
      // If iframe isn't loaded yet, load it first
      if (!iframe.src) {
        iframe.src = demoUrl;
        if (placeholderElement) {
          placeholderElement.style.display = 'none';
        }
        // Wait for load before fullscreen
        iframe.onload = () => {
          setTimeout(() => toggleFullscreen(iframe, fullscreenBtn), 500);
        };
      } else {
        toggleFullscreen(iframe, fullscreenBtn);
      }
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
    
    // Setup lazy loading for performance
    setupLazyLoading(iframe, demoUrl, placeholderElement);
    
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

  // Intersection Observer for lazy loading
  function setupLazyLoading(iframe, demoUrl, placeholderElement) {
    // Only setup if Intersection Observer is supported
    if (!('IntersectionObserver' in window)) {
      // Fallback: load immediately
      iframe.src = demoUrl;
      if (placeholderElement) {
        placeholderElement.style.display = 'none';
      }
      return;
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !iframe.src) {
          console.log('🔍 Loading demo on viewport entry:', demoUrl);
          
          // Show loading state
          if (placeholderElement) {
            placeholderElement.innerHTML = `
              <div style="display: flex; flex-direction: column; align-items: center; gap: 16px;">
                <div style="width: 40px; height: 40px; border: 4px solid #f3f3f3; border-top: 4px solid #007acc; border-radius: 50%; animation: spin 1s linear infinite;"></div>
                <p style="margin: 0; color: #666;">Loading interactive demo...</p>
              </div>
            `;
          }
          
          // Load the iframe after a small delay to prevent blocking
          setTimeout(() => {
            iframe.src = demoUrl;
            
            iframe.onload = () => {
              console.log('✅ Lazy-loaded demo ready');
              if (placeholderElement) {
                placeholderElement.style.display = 'none';
              }
            };
            
            iframe.onerror = () => {
              console.error('❌ Failed to lazy-load demo:', demoUrl);
              if (placeholderElement) {
                placeholderElement.innerHTML = `
                  <div style="text-align: center; color: #d73a49;">
                    <p>⚠️ Failed to load demo</p>
                    <a href="${demoUrl}" target="_blank" style="color: #007acc;">Open in new tab</a>
                  </div>
                `;
              }
            };
          }, 100);
          
          // Disconnect observer after loading
          observer.unobserve(entry.target);
        }
      });
    }, {
      // Load when 20% of the element is visible
      threshold: 0.2,
      // Pre-load 100px before element comes into view
      rootMargin: '100px 0px'
    });

    observer.observe(iframe);
  }
  
  // State management to prevent infinite loops
  const pluginState = {
    processedMarkers: new Set(),
    isProcessing: false,
    lastProcessTime: 0,
    initializationCount: 0
  };

  // Ultra-aggressive asynchronous demo initialization to prevent any blocking
  function initializeDemoEmbedsAsync() {
    // Prevent re-initialization if already processing or too frequent
    const now = Date.now();
    if (pluginState.isProcessing || (now - pluginState.lastProcessTime) < 500) {
      console.log('🚫 Skipping initialization - already processing or too frequent');
      return;
    }
    
    pluginState.initializationCount++;
    console.log(`🚀 Demo embed plugin initializing (ultra-async mode) - run #${pluginState.initializationCount}...`);
    
    // Limit initialization attempts to prevent runaway loops
    if (pluginState.initializationCount > 10) {
      console.warn('🛑 Too many initialization attempts, plugin disabled');
      return;
    }
    
    pluginState.isProcessing = true;
    pluginState.lastProcessTime = now;
    
    // Create a completely separate execution context using web worker simulation
    const workerCode = `
      self.onmessage = function() {
        self.postMessage('ready');
      };
    `;
    
    // Use multiple async strategies in parallel
    const strategies = [
      // Strategy 1: MessageChannel for complete context separation
      () => {
        const channel = new MessageChannel();
        channel.port2.onmessage = () => {
          try {
            processEmbeds();
          } finally {
            pluginState.isProcessing = false;
          }
        };
        setTimeout(() => channel.port1.postMessage('init'), 0);
      },
      
      // Strategy 2: requestIdleCallback with fallback
      () => {
        const scheduleWork = window.requestIdleCallback || 
          ((cb) => setTimeout(cb, 0));
        scheduleWork(() => {
          try {
            processEmbeds();
          } finally {
            pluginState.isProcessing = false;
          }
        }, { timeout: 100 });
      },
      
      // Strategy 3: Direct setTimeout with random delay to spread load
      () => {
        const randomDelay = Math.floor(Math.random() * 50) + 10;
        setTimeout(() => {
          try {
            processEmbeds();
          } finally {
            pluginState.isProcessing = false;
          }
        }, randomDelay);
      }
    ];
    
    // Execute only the first available strategy to avoid duplicate work
    strategies[0]();
    
    function processEmbeds() {
      try {
        initializeDemoEmbeds();
        console.log('✅ Demo embeds initialized successfully (ultra-async)');
      } catch (error) {
        console.error('❌ Error initializing demo embeds:', error);
        // Retry once with a different strategy
        setTimeout(() => {
          try {
            initializeDemoEmbeds();
          } catch (retryError) {
            console.error('❌ Retry also failed:', retryError);
          }
        }, 1000);
      }
    }
    
    // Return resolved promise immediately to prevent any waiting
    return Promise.resolve(null);
  }

  function initializeDemoEmbeds() {
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
    
    // Process markers in small batches to prevent blocking navigation
    const batchSize = 1; // Process 1 embed at a time for maximum responsiveness
    let currentBatch = 0;
    
    function processBatch() {
      const startIndex = currentBatch * batchSize;
      const endIndex = Math.min(startIndex + batchSize, embedMarkers.snapshotLength);
      
      for (let i = startIndex; i < endIndex; i++) {
        processEmbed(embedMarkers.snapshotItem(i), baseUrl);
      }
      
      currentBatch++;
      
      // Schedule next batch if there are more items
      if (currentBatch * batchSize < embedMarkers.snapshotLength) {
        // Use requestAnimationFrame for smooth, non-blocking processing
        requestAnimationFrame(processBatch);
      }
    }
    
    // Start processing with a small delay to ensure DOM is ready
    setTimeout(processBatch, 10);
  }
  
  function processEmbed(marker, baseUrl) {
    var markerText = marker.textContent.trim();
    
    // Create unique identifier for this marker
    const markerId = markerText + '_' + (marker.parentNode ? marker.parentNode.innerHTML.substring(0, 50) : '');
    
    // Check if this marker has already been processed
    if (pluginState.processedMarkers.has(markerId)) {
      console.log('🔄 Skipping already processed marker:', markerText);
      return;
    }
    
    // Check if container already exists for this marker
    const nextSibling = marker.nextSibling;
    if (nextSibling && nextSibling.classList && nextSibling.classList.contains('demo-container')) {
      console.log('🔄 Container already exists for marker:', markerText);
      pluginState.processedMarkers.add(markerId);
      return;
    }
    
    console.log('Processing marker:', markerText);
    
    // Mark this marker as processed
    pluginState.processedMarkers.add(markerId);
    
    // Parse the marker: <!-- start-embed-TYPE-/path/to/export?params -->
    var embedMatch = markerText.match(/start-embed-([a-zA-Z0-9-]+)-(.+)/);
    if (!embedMatch) {
      console.warn('Invalid embed marker format:', markerText);
      return;
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
    console.log(`  Current URL: ${window.location.href}`);
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
    var placeholderId = `placeholder-${sceneName}-${Date.now()}`;

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
        <!-- Loading placeholder -->
        <div id="${placeholderId}" class="demo-placeholder" style="
          position: absolute; 
          top: 0; 
          left: 0; 
          width: 100%; 
          height: 400px; 
          display: flex; 
          flex-direction: column; 
          align-items: center; 
          justify-content: center; 
          background: linear-gradient(145deg, #f8fafc, #e2e8f0); 
          border: 2px dashed #cbd5e1; 
          border-radius: 8px; 
          color: #64748b;
          z-index: 1;
          cursor: pointer;
          transition: all 0.3s ease;">
          <div style="text-align: center;">
            <div style="font-size: 48px; margin-bottom: 16px;">🎮</div>
            <h4 style="margin: 0 0 8px 0; color: #1e293b;">Interactive Demo Ready</h4>
            <p style="margin: 0; opacity: 0.8;">Click to load or scroll down to auto-load</p>
            <small style="opacity: 0.6; margin-top: 8px; display: block;">Optimized for performance</small>
          </div>
        </div>
        <!-- Iframe (loaded lazily) -->
        <iframe 
          id="${iframeId}" 
          width="800" 
          height="600" 
          frameborder="0"
          allowfullscreen="true"
          webkitallowfullscreen="true"
          mozallowfullscreen="true"
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

    // Get the placeholder element for lazy loading
    var placeholderElement = document.getElementById(placeholderId);
    
    // Add click-to-load functionality to placeholder
    if (placeholderElement) {
      placeholderElement.addEventListener('click', function() {
        var iframe = document.getElementById(iframeId);
        if (iframe && !iframe.src) {
          console.log('🖱️ User clicked to load demo:', sceneName);
          iframe.src = fullDemoUrl;
          placeholderElement.style.display = 'none';
        }
      });
    }
    
    // Add event listeners for enhanced functionality (deferred with extra delay)
    setTimeout(() => {
      setupDemoControls(iframeId, fullscreenBtnId, popoutBtnId, fullDemoUrl, sceneName, placeholderElement);
    }, 100); // Increased delay to ensure non-blocking
    
    console.log('  ✅ Enhanced iframe container created for:', sceneName);
  }
  
  // Completely decouple from Docsify hooks to prevent navigation blocking
  function initializePluginAggressively() {
    console.log('🔄 Setting up aggressive non-blocking demo embed system...');
    
    // Use MessageChannel for complete execution context separation
    const channel = new MessageChannel();
    channel.port2.onmessage = function() {
      initializeDemoEmbedsAsync();
    };
    
    // Monitor route changes independently using multiple strategies
    let lastUrl = window.location.href;
    
    function checkForPageChanges() {
      const currentUrl = window.location.href;
      if (currentUrl !== lastUrl) {
        console.log('🔄 Route change detected, scheduling demo initialization');
        lastUrl = currentUrl;
        
        // Clear processed markers on route change
        pluginState.processedMarkers.clear();
        pluginState.initializationCount = 0; // Reset initialization counter
        
        // Triple-layer async separation using MessageChannel
        setTimeout(() => {
          channel.port1.postMessage('init');
        }, 0);
      }
    }
    
    // Strategy 1: Monitor hash changes (primary Docsify navigation method)
    window.addEventListener('hashchange', () => {
      setTimeout(checkForPageChanges, 50); // Small delay to let Docsify finish rendering
    });
    
    // Strategy 2: Monitor DOM changes using MutationObserver (with smart filtering)
    const observer = new MutationObserver((mutations) => {
      let hasRelevantContentChange = false;
      
      mutations.forEach(mutation => {
        // Only trigger on content changes, not on plugin-generated changes
        if (mutation.type === 'childList') {
          // Check if this is a relevant target (main content areas)
          const isRelevantTarget = mutation.target.id === 'main' || 
                                   mutation.target.classList.contains('content') ||
                                   mutation.target.classList.contains('markdown-section');
          
          if (isRelevantTarget) {
            // Check if any added nodes are NOT our demo containers
            const addedNodes = Array.from(mutation.addedNodes);
            const hasNonPluginContent = addedNodes.some(node => {
              // Skip our own containers
              if (node.nodeType === Node.ELEMENT_NODE && 
                  node.classList && 
                  node.classList.contains('demo-container')) {
                return false;
              }
              
              // Skip text nodes that are just whitespace
              if (node.nodeType === Node.TEXT_NODE && 
                  node.textContent.trim() === '') {
                return false;
              }
              
              // This is genuine content change
              return true;
            });
            
            if (hasNonPluginContent) {
              hasRelevantContentChange = true;
            }
          }
        }
      });
      
      if (hasRelevantContentChange) {
        console.log('🔍 Relevant content change detected by MutationObserver');
        // Clear processed markers on genuine page changes
        pluginState.processedMarkers.clear();
        
        // Debounce to avoid multiple rapid triggers
        clearTimeout(observer.debounceTimer);
        observer.debounceTimer = setTimeout(() => {
          channel.port1.postMessage('init');
        }, 200); // Increased debounce time
      }
    });
    
    // Observe the main content area
    const mainElement = document.getElementById('main') || document.body;
    observer.observe(mainElement, {
      childList: true,
      subtree: true
    });
    
    // Strategy 3: Periodic check as fallback (every 2 seconds, low frequency)
    setInterval(checkForPageChanges, 2000);
    
    // Initial load
    setTimeout(() => {
      channel.port1.postMessage('init');
    }, 500); // Give Docsify time to initialize
  }
  
  // Minimal Docsify plugin registration (no blocking operations)
  window.$docsify = window.$docsify || {};
  window.$docsify.plugins = (window.$docsify.plugins || []).concat(function(hook) {
    // Use hook.ready() instead of hook.doneEach() to avoid per-page blocking
    hook.ready(function() {
      // Completely detach initialization from hook system
      setTimeout(initializePluginAggressively, 0);
    });
  });
  
  console.log('🎮 Demo embed plugin loaded (ultra-async version)');
  
  // Performance monitoring for navigation debugging
  let navigationStartTime = null;
  
  // Monitor navigation performance
  window.addEventListener('hashchange', () => {
    navigationStartTime = performance.now();
    console.log('🔄 Navigation started at:', navigationStartTime);
  });
  
  // Monitor when page content is ready
  const originalSetTimeout = window.setTimeout;
  let embedInitStartTime = null;
  
  // Override setTimeout to track our async operations
  window.setTimeout = function(callback, delay, ...args) {
    if (callback.toString().includes('initializeDemoEmbeds')) {
      embedInitStartTime = performance.now();
      console.log('⏱️ Embed initialization scheduled at:', embedInitStartTime);
      
      const wrappedCallback = function() {
        const embedInitEndTime = performance.now();
        console.log('⏱️ Embed initialization completed at:', embedInitEndTime);
        if (navigationStartTime) {
          console.log(`📊 Navigation to embed completion: ${embedInitEndTime - navigationStartTime}ms`);
        }
        return callback.apply(this, arguments);
      };
      
      return originalSetTimeout.call(this, wrappedCallback, delay, ...args);
    }
    return originalSetTimeout.call(this, callback, delay, ...args);
  };
})();
