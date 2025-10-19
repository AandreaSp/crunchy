import java.util.Properties

val secretsFile = file("../secrets.properties")
val outputFile = file("../../lib/generated/secrets.g.dart")

tasks.register("generateDartSecrets") {
    doLast {
        if (!secretsFile.exists()) {
            logger.warn("File secrets.properties non trovato: ${secretsFile.absolutePath}")
            outputFile.parentFile.mkdirs()
            outputFile.writeText("// No secrets")
            return@doLast
        }
        val props = Properties().apply { load(secretsFile.inputStream()) }
        val mapsKey = (props.getProperty("MAPS_API_KEY") ?: "").trim()
        val newsKey = (props.getProperty("NEWS_API_KEY") ?: "").trim()
        val dart = """
            // Generated. Do not edit.
            // Source: android/secrets.properties
            class AppSecrets {
              static const String mapsKey = '$mapsKey';
              static const String placesKey = '$mapsKey';
              static const String newsKey = '$newsKey';
            }
        """.trimIndent()
        outputFile.parentFile.mkdirs()
        outputFile.writeText(dart)
        logger.lifecycle("Wrote ${outputFile.absolutePath}")
    }
}