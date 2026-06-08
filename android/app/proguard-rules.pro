# BouncyCastle references JNDI/LDAP classes not available on Android
-dontwarn javax.naming.**
-dontwarn javax.naming.directory.**

# jmrtd / scuba
-dontwarn org.jmrtd.**
-dontwarn net.sf.scuba.**

-keep class com.au10tix.** { *; }
-keep class com.google.** { *; }
