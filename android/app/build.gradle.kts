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
        // 🔽 Ganti ke 1.8 agar konsisten
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        // 🔽 Ganti ke 1.8 agar konsisten
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.upih_pet_grooming"
        
        // 🔽 INI ADALAH PERBAIKAN UTAMANYA 🔽
        // Hapus 'flutter.minSdkVersion' dan tulis angkanya langsung
        minSdk = flutter.minSdkVersion
        // 🔼 BATAS PERBAIKAN 🔼

        targetSdk = 34 // Ini tidak apa-apa
        versionCode = 1
        versionName = "1.0.0"

        multiDexEnabled = true
    }

    dependencies {
        implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.10")
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
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
