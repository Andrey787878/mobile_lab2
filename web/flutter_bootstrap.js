{{flutter_js}}
{{flutter_build_config}}

const config = {
  canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).href,
};

function showLoadingError(error) {
  console.error('Не удалось запустить конвертер:', error);
  const loading = document.getElementById('loading');
  if (loading) {
    loading.textContent = 'Не удалось загрузить приложение. Обновите страницу.';
  }
}

_flutter.loader.load({
  config,
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine(config);
      await appRunner.runApp();
      document.getElementById('loading')?.remove();
    } catch (error) {
      showLoadingError(error);
    }
  },
}).catch(showLoadingError);
