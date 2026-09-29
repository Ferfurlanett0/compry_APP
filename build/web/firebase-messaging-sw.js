importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDrPX0wZjsUMOw272lndPT3Xa9a6zqemSc',
  appId: '1:335695394633:web:c29973770af32db110cc98',
  messagingSenderId: '335695394633',
  projectId: 'listapro-prod',
  authDomain: 'listapro-prod.firebaseapp.com',
  storageBucket: 'listapro-prod.firebasestorage.app'
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  const data = payload.data || {};
  self.registration.showNotification(notification.title || 'Compry', {
    body: notification.body || 'Há uma atualização em suas listas.',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: { url: data.route || '/notifications' }
  });
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const target = event.notification.data?.url || '/notifications';
  event.waitUntil(clients.openWindow(target));
});
