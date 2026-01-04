import { initializeApp } from 'firebase/app';
import { getMessaging, getToken, onMessage } from 'firebase/messaging';

const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_FIREBASE_APP_ID
};

let app;
let messaging;

try {
  if (firebaseConfig.apiKey && firebaseConfig.projectId) {
    app = initializeApp(firebaseConfig);
    messaging = getMessaging(app);
  }
} catch (err) {
  console.warn('Firebase init failed:', err);
}

export { messaging };

export const requestNotificationPermission = async () => {
  if (!messaging) return null;

  try {
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') return null;

    const token = await getToken(messaging, {
      vapidKey: process.env.REACT_APP_FIREBASE_VAPID_KEY
    });

    return token;
  } catch (err) {
    console.error('FCM error:', err);
    return null;
  }
};

export const onMessageListener = () =>
  messaging
    ? new Promise((resolve) => onMessage(messaging, resolve))
    : Promise.resolve(null);

if (typeof window !== 'undefined' && 'serviceWorker' in navigator && messaging) {
  navigator.serviceWorker.register('/firebase-messaging-sw.js');
}

export default app;
