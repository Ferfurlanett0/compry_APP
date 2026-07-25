// Dummy Service Worker for Firebase Messaging to prevent 404 errors in Web
self.addEventListener('install', function(e) {
  self.skipWaiting();
});
self.addEventListener('activate', function(e) {
  e.waitUntil(self.clients.claim());
});
