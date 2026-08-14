# Regles de reduction pour la compilation de production (EXI-SEC09).

# Flutter / plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# drift / sqlite3 : chargement natif par reflexion
-keep class com.google.android.gms.** { *; }
-dontwarn org.sqlite.**

# flutter_secure_storage : Keystore (EXI-SEC03)
-keep class androidx.security.crypto.** { *; }

# Ne jamais conserver les numeros de ligne d'origine sans le fichier source
# associe : les symboles partent au service de diagnostic (§16.3), pas dans l'APK.
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
