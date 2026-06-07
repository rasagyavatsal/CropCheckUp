buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencyLocking {
        lockAllConfigurations()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
    dependencyLocking {
        lockAllConfigurations()
    }
}

tasks.register("resolveAndLockAll") {
    doFirst {
        require(gradle.startParameter.isWriteDependencyLocks) {
            "Must be run with --write-locks"
        }
    }
    doLast {
        allprojects {
            configurations.filter { it.isCanBeResolved }.forEach {
                try {
                    it.resolve()
                } catch (e: Exception) {
                    // Ignore resolution failures
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    group = "build"
    description = "Deletes the build directory."
    delete(rootProject.layout.buildDirectory)
}
