{{flutter_js}}
{{flutter_build_config}}

(function() {
  const removeSplash = function() {
    const splash = document.getElementById('splash');
    if (splash) {
      splash.classList.add('fade-out');
      setTimeout(() => {
        if (splash && splash.parentNode) {
          splash.remove();
        }
      }, 1000); // Give it a full second to fade out nicely
    }
  };

  _flutter.loader.load({
    onEntrypointLoaded: async function(engineInitializer) {
      try {
        const appRunner = await engineInitializer.initializeEngine();
        // We remove the splash screen as soon as the engine is ready.
        // The Dart code in main.dart will then take over and show its own loading if needed.
        removeSplash();
        await appRunner.runApp();
      } catch (error) {
        console.error('Flutter boot failed:', error);
        removeSplash();
      }
    }
  });

  // Fail-safe: remove splash after 20 seconds
  setTimeout(removeSplash, 20000);
})();
