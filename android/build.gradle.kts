allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null && android.namespace == null) {
            val manifestFile = project.file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val manifestContent = manifestFile.readText()
                val match = Regex("""package=["']([^"']+)["']""").find(manifestContent)
                if (match != null) {
                    android.namespace = match.groupValues[1]
                } else {
                    val cleanName = project.name.replace("[^a-zA-Z0-9_]".toRegex(), "_")
                    android.namespace = "com.example.$cleanName"
                }
            } else {
                val cleanName = project.name.replace("[^a-zA-Z0-9_]".toRegex(), "_")
                android.namespace = "com.example.$cleanName"
            }
        }
    }
    plugins.withId("com.android.application") {
        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null && android.namespace == null) {
            val manifestFile = project.file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val manifestContent = manifestFile.readText()
                val match = Regex("""package=["']([^"']+)["']""").find(manifestContent)
                if (match != null) {
                    android.namespace = match.groupValues[1]
                } else {
                    val cleanName = project.name.replace("[^a-zA-Z0-9_]".toRegex(), "_")
                    android.namespace = "com.example.$cleanName"
                }
            } else {
                val cleanName = project.name.replace("[^a-zA-Z0-9_]".toRegex(), "_")
                android.namespace = "com.example.$cleanName"
            }
        }
    }
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


