'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "01d412f7da32a9590b52e8787d1e5694",
"assets/AssetManifest.bin.json": "eabbf41cc3e651f5b429bb6ae356310a",
"assets/AssetManifest.json": "4370b54af9d91e0b01f424d7ae5c0da2",
"assets/assets/fonts/Roboto-Bold.ttf": "ecec6c79a27c8914400d4116e02668aa",
"assets/assets/fonts/Roboto-Medium.ttf": "54feedcd3c51096071c45ab2e0054b35",
"assets/assets/fonts/Roboto-Regular.ttf": "2e2946d27be0d3d91e36c587bd7b0506",
"assets/assets/fonts/Roboto-SemiBold.ttf": "2e2946d27be0d3d91e36c587bd7b0506",
"assets/assets/icons/compry%2520logo%2520com%2520texto.svg": "65396b531c8af8f33a61197c49d39bff",
"assets/assets/icons/compry_logo.svg": "253defa5e9dcf61795035a90bd2c9312",
"assets/assets/icons/compry_logo_text.svg": "65396b531c8af8f33a61197c49d39bff",
"assets/assets/icons/empty.png": "60f33f1e6e70d83642340cd4eff6dbbd",
"assets/assets/icons/icone_compry.png": "978c8d98fad5a5c7fe3e0ef22b5b66c8",
"assets/assets/icons/icone_compry.svg": "91ea918914c70fd5254e77fdbf4eea53",
"assets/assets/icons/icone_compry_cropped.png": "450d6eac6c2d1e6d450b68fb6b2228f1",
"assets/assets/images/administrador.png": "be74906e64c7520496cc1443b49d1e81",
"assets/assets/images/funcionario.png": "71b00a48ecd0fba3eab8a8858d0b7713",
"assets/FontManifest.json": "e83983dce1b86afb382d68dd3d139de5",
"assets/fonts/MaterialIcons-Regular.otf": "d20384d2f353e74644993aecf08dbcd8",
"assets/NOTICES": "2b13b9958cede1af0082c7b8895e14cf",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "978c8d98fad5a5c7fe3e0ef22b5b66c8",
"firebase-messaging-sw.js": "19b8046d4c9572a90a7565c2386e2633",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "784be2df1ccf20bd37df31e9d62a0264",
"icons/compry%20logo%20com%20texto.svg": "65396b531c8af8f33a61197c49d39bff",
"icons/Icon-192.png": "978c8d98fad5a5c7fe3e0ef22b5b66c8",
"icons/Icon-512.png": "978c8d98fad5a5c7fe3e0ef22b5b66c8",
"icons/Icon-maskable-192.png": "978c8d98fad5a5c7fe3e0ef22b5b66c8",
"icons/Icon-maskable-512.png": "978c8d98fad5a5c7fe3e0ef22b5b66c8",
"icons/icone_compry.png": "978c8d98fad5a5c7fe3e0ef22b5b66c8",
"icons/icone_compry.svg": "91ea918914c70fd5254e77fdbf4eea53",
"index.html": "cc7537c809b58637eb639ae148185a00",
"/": "cc7537c809b58637eb639ae148185a00",
"main.dart.js": "17ff161f2ffa545a8dc8b152a9b4dcf7",
"manifest.json": "f6b7f4c35852a3ed383e7bfd663da5f4",
"vercel.json": "d6b75ff95ef7100f9ff75e47eb367f2c",
"version.json": "2f6721267d0ac66b2724ae8328192f0e"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
