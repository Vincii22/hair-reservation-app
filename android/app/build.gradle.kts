import java.io.FileInputStream
import java.util.Properties

// --- START: SIGNING CONFIGURATION IN KOTLIN DSL ---

// 1. Load the signing properties file
val signingProperties = Properties()
val signingPropertiesFile = rootProject.file("key.properties")

if (signingPropertiesFile.exists()) {
    FileInputStream(signingPropertiesFile).use { signingProperties.load(it) }
} else {
    println("Warning: key.properties file not found. Release build signing may fail.")
}

// 2. Define the signing configuration block using the properties
// This block must be inside the android { ... } block in standard Flutter setup,
// but defining it here simplifies access to the 'signingProperties' val.
// We will move the configuration *definition* inside the android block below.

// --- END: SIGNING CONFIGURATION IN KOTLIN DSL ---

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.salonapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.example.salonapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode as Int? ?: 1
        versionName = flutter.versionName
    }

    // 3. Define signingConfigs block and create the 'release' config
    signingConfigs {
        create("release") {
            storeFile = file(signingProperties["storeFile"] as String)
            storePassword = signingProperties["storePassword"] as String
            keyAlias = signingProperties["keyAlias"] as String
            keyPassword = signingProperties["keyPassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            // FIX: Use the created 'release' signing configuration
            signingConfig = signingConfigs.getByName("release")
            
            // RECOMMENDED: Optimization for release build
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}

flutter {
    source = "../.."
}