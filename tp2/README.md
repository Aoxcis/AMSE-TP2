# AMSE-TP2

## TODO
**add gradle.propreties in android folder with this code**

```
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
org.gradle.java.home=your_java17_path
```

## To deploy in apk or appbundle signed

# create the keystore file

execute this command in powershell : 
```
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks `
        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
        -alias upload
```


# create key.properties file in android folder

code : 

```
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=C:/Users/username/upload-keystore.jks
```