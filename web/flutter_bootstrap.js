{{flutter_js}}
{{flutter_build_config}}

window.compryPwaDiagnostic?.('bootstrap-start');

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    window.compryPwaDiagnostic?.('entrypoint-loaded');
    try {
      const appRunner = await engineInitializer.initializeEngine();
      window.compryPwaDiagnostic?.('engine-initialized');
      await appRunner.runApp();
      window.compryPwaDiagnostic?.('run-app-complete');
    } catch (error) {
      window.compryAppLoadingFailed?.(error);
      throw error;
    }
  }
});
