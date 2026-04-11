allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// AGP 8.x 이상에서는 모든 library 모듈에 namespace 명시가 필수.
// isar_flutter_libs 3.x 등 구버전 패키지 대응: AndroidManifest.xml의 package 속성에서 자동 추출.
subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            val android = extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
            if (android != null && android.namespace.isNullOrEmpty()) {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val pkg = Regex("""package\s*=\s*"([^"]+)"""")
                        .find(manifestFile.readText())?.groupValues?.get(1)
                    if (pkg != null) android.namespace = pkg
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
