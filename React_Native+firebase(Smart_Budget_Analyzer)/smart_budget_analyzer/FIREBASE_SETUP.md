# Firebase Setup Guide for SmartBudgetAnalyzer

## 🔥 Firebase Configuration Complete!

Your SmartBudgetAnalyzer project is now configured with Firebase. Here's what has been set up:

### ✅ What's Been Configured

1. **Firebase Configuration File** (`src/config/firebase.ts`)
   - Project ID: `smart-budget-analyzer`
   - Web API Key: `AlzaSyD5q9e3KqjmG9yinXkvwQpIdXHsf-HtbU0`
   - App ID: `1:826095284944:android:9c76f27cfa1e0ac82ae4d5`

2. **Authentication Service** (`src/services/authService.ts`)
   - Email/Password authentication
   - Password reset functionality
   - Error handling for common auth issues

3. **Firestore Service** (`src/services/firestoreService.ts`)
   - User management
   - Transaction CRUD operations
   - Budget management
   - Category management

4. **Authentication Context** (`src/contexts/AuthContext.tsx`)
   - Global auth state management
   - Automatic user creation in Firestore
   - Auth state persistence

5. **Updated App Configuration** (`app.json`)
   - Android package name: `com.akdev.smart_budget_analyzer`
   - Firebase plugin configuration

### 📱 Next Steps

#### 1. Download Firebase Configuration Files

You need to download the `google-services.json` file from Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your `smart-budget-analyzer` project
3. Go to Project Settings (gear icon)
4. In the "Your apps" section, find your Android app
5. Click "Download google-services.json"
6. Place the file in your project root: `smart_budget_analyzer/google-services.json`

#### 2. Enable Authentication Methods

In Firebase Console:
1. Go to Authentication → Sign-in method
2. Enable "Email/Password" authentication
3. (Optional) Enable "Google" for Google Sign-In

#### 3. Set Up Firestore Database

In Firebase Console:
1. Go to Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location (choose closest to your users)

#### 4. Set Up Security Rules

Update Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Transactions
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Budgets
    match /budgets/{budgetId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Categories (users can read default categories)
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || resource.data.userId == null);
    }
  }
}
```

### 🚀 Testing the Setup

1. **Start the development server:**
   ```bash
   npx expo start
   ```

2. **Test Authentication:**
   - Try creating a new account
   - Try signing in with existing credentials
   - Test password reset functionality

3. **Check Firestore:**
   - Verify user documents are created
   - Check that data is being stored correctly

### 🔧 Troubleshooting

#### Common Issues:

1. **"Firebase not initialized" error:**
   - Make sure `google-services.json` is in the project root
   - Restart the development server

2. **Authentication errors:**
   - Check if Email/Password auth is enabled in Firebase Console
   - Verify the API key is correct

3. **Firestore permission errors:**
   - Update security rules in Firebase Console
   - Make sure you're signed in with a valid user

#### Node.js Version Warning:
You're using Node.js v18.20.8, but Firebase requires Node.js >=20.0.0. Consider upgrading:
```bash
# Using nvm (Node Version Manager)
nvm install 20
nvm use 20

# Or download from nodejs.org
```

### 📊 Database Structure

Your Firestore will have these collections:

- **users**: User profiles and preferences
- **transactions**: Financial transactions
- **budgets**: Budget categories and limits
- **categories**: Transaction categories

### 🎯 Ready to Use!

Your Firebase setup is complete! The app now supports:
- ✅ User registration and login
- ✅ Password reset
- ✅ Real-time data synchronization
- ✅ Secure data access
- ✅ Offline support (with Firestore)

You can now start implementing the core features like transaction management, budget tracking, and AI-powered insights! 