plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "mg.majichrono.majichrono"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Requis par flutter_local_notifications et drift sur API 26 (EXI-P09).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "mg.majichrono"
        // Android 8.0 minimum, impose par le §2.1 du cahier des charges :
        // c'est le plancher du parc d'entree de gamme malgache (§4.4).
        minSdk = 26
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Un APK **par** architecture (EXI-P03 : moins de 25 Mo).
    //
    // `ndk.abiFilters` faisait exactement l'inverse de ce que son commentaire
    // annoncait : il empilait les trois architectures dans un seul APK. Les
    // bibliotheques natives des plugins — surtout le lecteur de code-barres ML
    // Kit, pres de 5 Mo par ABI — etaient donc livrees trois fois a chaque
    // utilisateur, dont deux qu'il n'executera jamais.
    //
    // Le decoupage par architecture est confie a Flutter, pas a Gradle.
    //
    // Un bloc `splits { abi { ... } }` a longtemps figure ici, desactive des que
    // `target-platform` etait pose. Il ne s'est jamais applique : `flutter build
    // apk` pose **toujours** cette propriete, avec la liste par defaut des trois
    // architectures. Le garde-fou desactivait donc le decoupage a chaque
    // compilation, et l'APK embarquait les trois jeux de bibliotheques natives —
    // 87 Mo la ou le budget est de 25.
    //
    // La bonne commande est `flutter build apk --split-per-abi`, qui produit un
    // fichier par architecture sans que Gradle ait a s'en meler.

    buildTypes {
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
        release {
            // TODO(lot 6) : cle de signature de production.
            signingConfig = signingConfigs.getByName("debug")
            // EXI-SEC09 : obfuscation et minification actives en production.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    packaging {
        resources {
            excludes += setOf("/META-INF/{AL2.0,LGPL2.1}")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
