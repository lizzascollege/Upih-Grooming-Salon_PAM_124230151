plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.upih_pet_grooming"
    
    // Ini sudah BENAR
    compileSdk = 36 
    // ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {

        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.upih_pet_grooming"
        minSdk = flutter.minSdkVersion
        targetSdk = 34 
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    dependencies {
        implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.10")
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
        implementation("androidx.multidex:multidex:2.0.1")
    }


    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
