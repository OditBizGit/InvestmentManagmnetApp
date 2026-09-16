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

// Force plugin Android libraries (e.g. file_picker on SDK 34) to compileSdk 36
// so they can consume dependencies that require API 36.
// Uses finalizeDsl (not afterEvaluate) to avoid clashing with evaluationDependsOn(":app").
subprojects {
    pluginManager.withPlugin("com.android.library") {
        extensions
            .findByType(com.android.build.api.variant.LibraryAndroidComponentsExtension::class.java)
            ?.finalizeDsl { extension ->
                extension.compileSdk = 36
            }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
