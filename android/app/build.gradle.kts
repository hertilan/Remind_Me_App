plugins {
    id("com.android.application")
    id("kotlin-android")
    // Add the Google services Gradle plugin for Firebase
    id("com.google.gms.google-services") // <-- ADD THIS LINE
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.remind_me_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.remind_me_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM (Bill of Materials) - This is crucial for managing Firebase versions
    // Check for the latest Firebase Android BoM version if possible
    implementation(platform("com.google.firebase:firebase-bom:33.1.0")) // <-- ADD THIS LINE (UPDATE VERSION IF NEWER)

    // Add the dependencies for any Firebase products you want to use in your Flutter app
    // These correspond to the Flutter Firebase packages you've added (e.g., firebase_core, firebase_auth)
    // When using the BoM, you do NOT specify versions for individual Firebase dependencies here.
    implementation("com.google.firebase:firebase-analytics") // Example: If you added firebase_analytics
    // If you added firebase_auth:
    // implementation("com.google.firebase:firebase-auth")
    // If you added cloud_firestore:
    // implementation("com.google.firebase:firebase-firestore")
    // If you added firebase_storage:
    // implementation("com.google.firebase:firebase-storage")
    // Add other Firebase SDKs here as needed for your Flutter packages
}
apply(plugin = "com.google.gms.google-services")
