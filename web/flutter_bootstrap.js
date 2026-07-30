{{flutter_js}}
{{flutter_build_config}}

window.compryPwaDiagnostic?.('bootstrap-start');

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  },
  onEntrypointLoaded: async function(engineInitializer) {
    window.compryPwaDiagnostic?.('entrypoint-loaded');
    const appRunner = await engineInitializer.initializeEngine();
    window.compryPwaDiagnostic?.('engine-initialized');
    await appRunner.runApp();
    window.compryPwaDiagnostic?.('run-app-complete');
  }
});
