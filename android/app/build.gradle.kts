import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties().apply {
    val propertiesFile = rootProject.file("local.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { load(it) }
    }
}

// Release/upload keystore config. android/key.properties is gitignored and
// machine-specific (like local.properties) - it is never committed. When it
// is absent (e.g. a contributor's machine without the keystore, or CI),
// release builds fall back to debug signing so `flutter build apk --release`
// still works, just not signed for real distribution.
val keyProperties = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use { load(it) }
    }
}
val hasReleaseSigning = keyProperties.getProperty("storeFile") != null

android {
    namespace = "in.nammarane.bennur"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "in.nammarane.bennur"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Read from an env var first, same reasoning and pattern as the
        // signing passwords below: repeated attempts to edit this value into
        // local.properties silently failed to save (the placeholder stayed
        // in place every time), so this sidesteps file-editing entirely. Set
        // NAMMA_MAPS_ANDROID_KEY in the same terminal session before
        // building to use this path.
        manifestPlaceholders["GOOGLE_MAPS_ANDROID_KEY"] =
            System.getenv("NAMMA_MAPS_ANDROID_KEY")
                ?: localProperties.getProperty("google.maps.androidKey", "MAPS_KEY_NOT_CONFIGURED")
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                // Passwords are read from environment variables first, falling
                // back to key.properties. This avoids a whole class of Java
                // .properties escaping bugs (a password containing '#', '=',
                // ':' or '!' gets silently mangled by Properties parsing;
                // saving from different editors can also introduce a BOM that
                // corrupts the first key). Set NAMMA_STORE_PASSWORD /
                // NAMMA_KEY_PASSWORD in the same terminal session before
                // building to use this path.
                storePassword = System.getenv("NAMMA_STORE_PASSWORD") ?: keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = System.getenv("NAMMA_KEY_PASSWORD") ?: keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // No android/key.properties on this machine - fall back to
                // debug signing so the build still succeeds. Never publish
                // an APK built this way; see FINAL_RELEASE_CHECKLIST.md.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
