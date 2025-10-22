import java.util.Properties
import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

/* ---- Parsing dart-defines → mappa chiave/valore ---- */
val dartEnv: Map<String, String> =
    (project.findProperty("dart-defines") as String?)
        ?.split(",")
        ?.map { String(Base64.getDecoder().decode(it), Charsets.UTF_8) }
        ?.mapNotNull { s ->
            val i = s.indexOf('=')
            if (i > -1) s.substring(0, i) to s.substring(i + 1) else null
        }
        ?.toMap()
        ?: emptyMap()

/* ---- Unica sorgente per MAPS_API_KEY (niente secrets.properties) ---- */
val MAPS_API_KEY: String = dartEnv["MAPS_API_KEY"] ?: ""

/* ---- Fail-fast solo quando serve (build/install), non su clean/sync ---- */
val requestedTasks = gradle.startParameter.taskNames.map { it.lowercase() }
val needsMapsKey = requestedTasks.any { t ->
    listOf("assemble", "bundle", "install", "package", "process", "merge")
        .any { key -> t.contains(key) }
}
val isCleanOnly = requestedTasks.isNotEmpty() && requestedTasks.all { it.contains("clean") }

val isCI =
    (System.getenv("CI") ?: "").equals("true", ignoreCase = true) ||
    (System.getenv("GITHUB_ACTIONS") ?: "").equals("true", ignoreCase = true)

if (!isCI && needsMapsKey && !isCleanOnly && MAPS_API_KEY.isBlank()) {
    throw GradleException("MAPS_API_KEY mancante. Usa --dart-define/local.properties/ENV.")
}

/* ---- Config modulo Android + placeholder per Maps ---- */
android {
    /* ---- namespace + SDK ---- */
    namespace = "com.example.crunchy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    /* ---- Java/Kotlin ---- */
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    /* ---- Impostazioni base dell'APK + placeholder per il Manifest ---- */
    defaultConfig {
        applicationId = "com.example.crunchy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        /* ---- Il Manifest userà ${MAPS_API_KEY} ---- */
        manifestPlaceholders["MAPS_API_KEY"] = MAPS_API_KEY
    }

    /* ---- Build types: niente shrinkResources in debug; release semplice ---- */
    buildTypes {
        debug {
        }
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

/* ---- Sorgente Flutter ---- */
flutter {
    source = "../.."
}
