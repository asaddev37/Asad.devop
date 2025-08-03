import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

// Your Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyD5q9e3KqjmG9yinXkvwQpIdXHsf-HtbU0",
  authDomain: "smart-budget-analyzer.firebaseapp.com",
  projectId: "smart-budget-analyzer",
  storageBucket: "smart-budget-analyzer.appspot.com",
  messagingSenderId: "826095284944",
  appId: "1:826095284944:android:9c76f27cfa1e0ac82ae4d5"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const auth = getAuth(app);
export const db = getFirestore(app);

// Export the app instance
export default app; 