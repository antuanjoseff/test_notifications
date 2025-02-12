importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');

   /*Update with yours config*/
  const firebaseConfig = {
    apiKey: "AIzaSyD1u36i97kjNAXK1tTsml6_HpFBYnUBdBQ",
    authDomain: "test-notifications-f6476.firebaseapp.com",
    projectId: "test-notifications-f6476",
    storageBucket: "test-notifications-f6476.firebasestorage.app",
    messagingSenderId: "414101353176",
    appId: "1:414101353176:web:a9c93048fb00ccfd429dad"
       
 };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });