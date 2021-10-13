importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");
var firebaseConfig = {
    apiKey: "AIzaSyDb-qyT1_I3E2Zct_vsvypohf5aYXQWRFc",
    authDomain: "travellersapp-e9daa.firebaseapp.com",
    databaseURL: "https://travellersapp-e9daa-default-rtdb.firebaseio.com",
    projectId: "travellersapp-e9daa",
    storageBucket: "travellersapp-e9daa.appspot.com",
    messagingSenderId: "137749759925",
    appId: "1:137749759925:web:4fc4bab8400f9c5ae6bbfc",
    measurementId: "G-T5QGL1CP8V"
  };
  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
  
  const messaging = firebase.messaging();