# Taquin - Jeu de Puzzle Coulissant

## Description

Taquin est une application mobile développée avec Flutter qui propose le célèbre jeu de puzzle coulissant où vous devez reconstituer une image en déplaçant des tuiles.

## Fonctionnalités

- **Différents niveaux de difficulté** : Facile, Normal, Difficile
- **Personnalisation du jeu** : Choisissez parmi différentes tailles de grille (3x3, 4x4, 5x5, etc.)
- **Sources d'images multiples** :
    - Images prédéfinies aléatoires
    - Photos de votre galerie
    - Photos prises avec l'appareil photo
- **Thème clair/sombre** : Personnalisez l'apparence de l'application
- **Statistiques de jeu** : Suivi du nombre de mouvements et du temps écoulé
- **Sauvegarde automatique** : Reprenez votre partie là où vous l'avez laissée

## Installation

### Prérequis

- Flutter SDK (version 3.0.0 ou supérieure)
- Android Studio ou VS Code avec les extensions Flutter
- Java JDK 17 ou supérieur

### Configuration

1. **Clonez le dépôt**
    
    git clone https://github.com/votre-utilisateur/AMSE-TP2.git
    
    cd AMSE-TP2/tp2
    
2. **Installez les dépendances**
    
    flutter pub get
    
3. **Configuration Android**

    Java 17 est nécessaire
    
    Créez un fichier `gradle.properties` dans le dossier `android` avec le contenu suivant :
    
    org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
    
    android.useAndroidX=true
    
    android.enableJetifier=true
    
    org.gradle.java.home=C:/Program Files/Java/jdk-17
    
    Remplacez le chemin Java par celui de votre installation.
    
4. **Lancer l'application**
    
    flutter run
    

## Comment jouer

1. **Démarrer une partie** : Choisissez une image et les paramètres de jeu (taille de grille et difficulté)
2. **Déplacer les tuiles** : Appuyez sur une tuile adjacente à l'espace vide pour la déplacer
3. **Objectif** : Recréez l'image originale en réarrangeant les tuiles dans le bon ordre
4. **Victoire** : Le jeu est terminé lorsque toutes les tuiles sont dans leur position d'origine

## Déploiement

### Générer un APK signé

1. **Créer un keystore** :
    
    keytool -genkey -v -keystore %USERPROFILE%\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
    
2. **Configurer le keystore** :
    
    Créez un fichier `key.properties` dans le dossier `android` :
	
    storePassword=votre_mot_de_passe
    
    keyPassword=votre_mot_de_passe
    
    keyAlias=upload
    
    storeFile=C:/Users/votre_nom/upload-keystore.jks
    
3. **Générer l'APK** :
    
    flutter build apk --release
    

## Résolution des problèmes courants

- **Images aléatoires ne s'affichant pas** : Vérifiez votre connexion internet et les autorisations réseau
- **Accès à la caméra/galerie refusé** : Accordez les autorisations requises dans les paramètres de votre appareil
- **Erreurs de compilation** : Assurez-vous que le chemin JDK dans `gradle.properties` est correct

## Installation rapide

Pour tester l'application sans avoir à la compiler, un fichier APK pré-compilé est disponible à la racine du projet. Cette version inclut toutes les fonctionnalités, notamment l'accès à la caméra et à la galerie de photos.

#### Instructions pour l'installation :

1. Téléchargez le fichier APK depuis la racine du projet
2. Sur votre appareil Android, autorisez l'installation d'applications provenant de sources inconnues dans les paramètres
3. Ouvrez le fichier APK téléchargé pour lancer l'installation
4. Une fois installée, accordez (si nécessaire) les autorisations nécessaires à l'application (caméra, galerie, etc.)

## Crédits

Développé par Grégoire PAUL et Pierre PROVOST - 2025

Licence MIT