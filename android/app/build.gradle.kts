import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val secretsProps = Properties().apply {
    val f = rootProject.file("android/secrets.properties")
    if (f.exists()) {
        f.inputStream().use { load(it) }
    }
}

val MAPS_API_KEY: String = secretsProps.getProperty("MAPS_API_KEY")
    ?: System.getenv("MAPS_API_KEY")
    ?: (project.findProperty("MAPS_API_KEY") as String?) ?: ""

val NEWS_API_KEY: String = secretsProps.getProperty("NEWS_API_KEY")
    ?: System.getenv("NEWS_API_KEY")
    ?: (project.findProperty("NEWS_API_KEY") as String?) ?: ""

android {
    namespace = "com.example.crunchy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.crunchy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders += mapOf(
            "MAPS_API_KEY" to MAPS_API_KEY
        )
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