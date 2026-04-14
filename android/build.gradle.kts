allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configure Kotlin for all subprojects
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            project.plugins.withType<org.jetbrains.kotlin.gradle.plugin.KotlinBasePluginWrapper> {
                project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
                    compilerOptions {
                        apiVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_9)
                        languageVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_9)
                    }
                }
            }
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
