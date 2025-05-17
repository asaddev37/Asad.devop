plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.task_management"
    compileSdk = 35
    ndkVersion = "27.0.12077973"


        compileOptions {
            isCoreLibraryDesugaringEnabled = true
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
        }

        kotlinOptions {
            jvmTarget = "11"  // Ensure Kotlin targets Java 11
        }



    defaultConfig {
        applicationId = "com.example.task_management"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// ✅ `dependencies {}` must be OUTSIDE `android {}`.
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.2")
}

flutter {
    source = "../.."
}
