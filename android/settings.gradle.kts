pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")

// Fix for Isar namespace issue with AGP 8+
// Set namespace for libraries that don't have one defined
gradle.beforeProject {
    if (project.name != "app" && project.buildFile.exists()) {
        project.afterEvaluate {
            if (project.hasProperty("android") && project.extensions.findByName("android") != null) {
                val android = project.extensions.getByName("android")
                try {
                    val namespaceProperty = android.javaClass.getMethod("getNamespace")
                    val currentNamespace = namespaceProperty.invoke(android) as? String
                    if (currentNamespace.isNullOrBlank()) {
                        val setNamespaceMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                        setNamespaceMethod.invoke(android, project.group.toString())
                    }
                } catch (e: Exception) {
                    // Ignore if methods don't exist - not a library module
                }
            }
        }
    }
}

