plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.turfly_new"
    compileSdk = flutter.compileSdkVersion
    // Set the NDK version to resolve compatibility issues with plugins.
    // This value was suggested by the previous error message.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.turfly_new" // Use '=' for assignment in Kotlin DSL
        minSdkVersion(23) // Use parentheses for function call in Kotlin DSL
        targetSdkVersion(flutter.targetSdkVersion) // Use parentheses for function call in Kotlin DSL
        versionCode = flutter.versionCode // Use '=' for assignment in Kotlin DSL
        versionName = flutter.versionName // Use '=' for assignment in Kotlin DSL
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
