importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyD1u36i97kjNAXK1tTsml6_HpFBYnUBdBQ",
  authDomain: "test-notifications-f6476.firebaseapp.com",
  projectId: "test-notifications-f6476",
  storageBucket: "test-notifications-f6476.firebasestorage.app",
  messagingSenderId: "414101353176",
  appId: "1:414101353176:web:a9c93048fb00ccfd429dad"  
});



const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});

