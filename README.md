# Supervision Audio Distribuée

## Présentation du projet

Ce projet est un système de diffusion audio centralisé conçu pour gérer plusieurs lecteurs audio répartis sur différents sites (gares, halls, zones publiques). Un tableau de bord web permet à un opérateur de contrôler en temps réel la musique diffusée sur chaque lecteur, de planifier des annonces automatiques et de gérer des playlists.

Le système est composé de trois parties distinctes qui communiquent entre elles :

- Un serveur Django qui centralise toutes les informations et expose une API
- Un tableau de bord React accessible depuis un navigateur web
- Un script Python qui tourne sur chaque ordinateur lecteur (dans chaque gare)

---

## Architecture du projet

```
projet_audio/
|
|-- core/                        # Configuration principale Django
|   |-- settings.py
|   |-- urls.py
|   |-- wsgi.py
|
|-- api/                         # Application Django principale
|   |-- models.py                # Structure de la base de données
|   |-- views.py                 # Logique métier et API REST
|   |-- urls.py                  # Routes de l'API
|   |-- serializers.py           # Sérialisation des données
|
|-- media/                       # Fichiers audio uploadés
|   |-- tracks/
|
|-- frontend/                    # Application React (tableau de bord)
|   |-- src/
|       |-- App.js               # Composant principal
|       |-- App.css              # Styles
|
|-- player_client.py             # Script lecteur (un par gare)
|-- manage.py
|-- requirements.txt
```

---

## Fonctionnement général

### Le serveur Django

Le serveur est le coeur du système. Il stocke toutes les informations dans une base de données MySQL et expose plusieurs routes API que le tableau de bord et les lecteurs utilisent pour communiquer.

### Le tableau de bord React

L'opérateur ouvre le tableau de bord dans son navigateur. Il peut voir en temps réel l'état de chaque lecteur (en ligne ou hors ligne), changer la playlist en cours, ajuster le volume et programmer des annonces à des heures précises.

### Le script lecteur (player_client.py)

Un script Python tourne en permanence sur chaque ordinateur de gare. Toutes les 3 secondes, il envoie un signal au serveur pour indiquer son état (en train de jouer ou inactif). En retour, le serveur lui indique quel morceau jouer. Le script télécharge le fichier audio et le joue via pygame.

### Cycle de fonctionnement

1. Le lecteur envoie son état au serveur toutes les 3 secondes
2. Le serveur répond avec l'URL du morceau à jouer
3. Le lecteur télécharge le fichier et le joue
4. Quand le morceau se termine, le lecteur envoie "IDLE" au serveur
5. Le serveur répond avec le morceau suivant dans la playlist
6. Le cycle recommence

### Gestion des alertes

Quand une alerte est programmée (annonce SNCF, message de sécurité), le serveur détecte l'heure et envoie l'URL de l'alerte au lecteur concerné. Le lecteur met en pause la musique d'ambiance, joue l'alerte jusqu'au bout, puis reprend la musique là où elle s'était arrêtée.

---

## Prérequis

- Ubuntu 20.04 ou supérieur
- Python 3.8 ou supérieur
- Node.js 18 ou supérieur
- MySQL 8.0 ou supérieur
- pip et npm installés

---

## Installation

### Etape 1 : Cloner ou copier le projet

```bash
cd ~
mkdir projet_audio
cd projet_audio
```

Copiez tous les fichiers du projet dans ce dossier.

### Etape 2 : Créer l'environnement virtuel Python

```bash
python3 -m venv venv
source venv/bin/activate
```

### Etape 3 : Installer les dépendances Python

```bash
pip install django djangorestframework django-cors-headers mysqlclient pygame requests
```

Ou si vous avez un fichier requirements.txt :

```bash
pip install -r requirements.txt
```

### Etape 4 : Créer la base de données MySQL

Connectez-vous à MySQL :

```bash
mysql -u root -p
```

Puis créez la base et l'utilisateur :

```sql
CREATE DATABASE audio_supervision_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'admin_audio'@'localhost' IDENTIFIED BY 'votre_mot_de_passe';
GRANT ALL PRIVILEGES ON audio_supervision_db.* TO 'admin_audio'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Etape 5 : Configurer Django

Ouvrez le fichier `core/settings.py` et vérifiez la section DATABASES :

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'audio_supervision_db',
        'USER': 'admin_audio',
        'PASSWORD': 'votre_mot_de_passe',
        'HOST': 'localhost',
        'PORT': '3306',
    }
}
```

Vérifiez aussi que ces paramètres sont présents :

```python
CORS_ALLOW_ALL_ORIGINS = True

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

TIME_ZONE = 'Europe/Paris'
USE_TZ = True
```

### Etape 6 : Appliquer les migrations

```bash
cd ~/projet_audio
source venv/bin/activate
python manage.py makemigrations
python manage.py migrate
```

### Etape 7 : Créer un compte administrateur

```bash
python manage.py createsuperuser
```

Suivez les instructions pour créer un nom d'utilisateur et un mot de passe.

### Etape 8 : Installer les dépendances React

```bash
cd ~/projet_audio/frontend
npm install
```

---

## Lancement du projet

### Lancer le serveur Django

Ouvrez un terminal et lancez :

```bash
cd ~/projet_audio
source venv/bin/activate
python manage.py runserver
```

Le serveur démarre sur http://127.0.0.1:8000

### Lancer le tableau de bord React

Ouvrez un second terminal et lancez :

```bash
cd ~/projet_audio/frontend
npm start
```

Le tableau de bord s'ouvre automatiquement sur http://localhost:3000

### Lancer un lecteur

Sur chaque ordinateur de gare, ouvrez un terminal et lancez :

```bash
cd ~/projet_audio
source venv/bin/activate
python player_client.py
```

Le lecteur se connecte au serveur et commence à attendre des instructions.

---

## Mode d'emploi

### Connexion au tableau de bord

Ouvrez un navigateur et allez sur http://localhost:3000

Un écran de connexion s'affiche. Entrez les identifiants configurés dans App.js (par défaut : maketing / 0000).

### Ajouter des fichiers audio

Pour ajouter des morceaux audio au système :

1. Allez sur http://127.0.0.1:8000/admin
2. Connectez-vous avec votre compte administrateur
3. Cliquez sur "Tracks" puis "Ajouter"
4. Donnez un titre et uploadez votre fichier MP3
5. Sauvegardez

### Créer une playlist

1. Dans le tableau de bord, ouvrez le panneau "Gestionnaire et Créateur de Playlists"
2. Donnez un nom à votre playlist
3. Selectionnez un morceau dans la liste et cliquez sur "Inserer"
4. Répétez pour ajouter plusieurs morceaux dans l'ordre souhaité
5. Cliquez sur "Enregistrer la Playlist"

### Assigner une playlist à un lecteur

Dans la grille des lecteurs en bas du tableau de bord, chaque carte représente un lecteur. Utilisez le menu déroulant "Playlist d'Ambiance" pour choisir la playlist à diffuser sur ce lecteur. Le changement est immédiat.

### Ajuster le volume

Utilisez le curseur de volume sur chaque carte lecteur. Le volume est mis à jour en temps réel sur le lecteur concerné.

### Synchroniser toutes les gares

Le bouton "Lancer Playlist Commune" dans la section Controle Global assigne la premiere playlist disponible à tous les lecteurs en même temps. Le bouton "Arret Global" coupe la diffusion sur tous les lecteurs.

### Programmer une alerte

1. Ouvrez le panneau "Planificateur de Lecture Globale et Locale"
2. Choisissez le jour de la semaine
3. Choisissez l'heure
4. Selectionnez le site cible (une gare spécifique ou toutes les gares)
5. Choisissez la playlist d'alerte à diffuser
6. Réglez le volume de l'alerte
7. Cliquez sur "Ajouter au Planning"

A l'heure programmée, le lecteur concerné met automatiquement en pause la musique d'ambiance, joue l'annonce, puis reprend la musique.

### Suivre l'état des lecteurs

La grille des lecteurs affiche en temps réel pour chaque site :

- Un indicateur vert (en ligne) ou rouge (hors ligne)
- Le statut ONLINE ou OFFLINE
- Le morceau en cours de lecture
- L'heure du dernier signal recu
- Les controles de playlist et de volume

Un lecteur passe en OFFLINE si le serveur ne reçoit pas de signal depuis plus de 15 secondes.

---

## Configuration du lecteur pour chaque gare

Ouvrez le fichier player_client.py et modifiez uniquement la ligne PLAYER_NAME en haut du fichier :

```python
PLAYER_NAME = "Lecteur_Gare_Lyon"   # Changez ce nom pour chaque gare
```

Les noms possibles doivent correspondre à ceux que vous avez enregistrés dans le système. Chaque lecteur doit avoir un nom unique.

Si le serveur Django ne tourne pas sur le même ordinateur que le lecteur, modifiez aussi l'adresse IP :

```python
API_URL = "http://192.168.1.100:8000/api/heartbeat/"   # Remplacez par l'IP du serveur
```

---

## Structure de la base de données

Le projet utilise six tables principales :

- Track : les fichiers audio disponibles (titre, fichier, date d'upload)
- Playlist : les playlists créées par l'opérateur
- PlaylistTrack : la liaison entre une playlist et ses morceaux avec leur ordre
- Player : les lecteurs enregistrés avec leur état et leur playlist assignée
- Schedule : les planifications d'ambiance par jour et heure
- ScheduledAlert : les annonces programmées avec leur playlist et leur site cible

---

## Résolution des problèmes courants

### Le lecteur reste OFFLINE

Vérifiez que le serveur Django est bien lancé et que l'adresse IP dans player_client.py est correcte. Vérifiez aussi que le pare-feu ne bloque pas le port 8000.

### Le son ne joue pas

Vérifiez que pygame est bien installé et que la carte son est accessible. Lancez le lecteur depuis un terminal et observez les messages de log.

### Erreur 500 sur le serveur

Regardez la console Django pour le message d'erreur complet. Les causes les plus fréquentes sont une migration manquante ou un champ manquant en base de données.

### La playlist ne progresse pas

Vérifiez que les PlaylistTrack sont bien enregistrées en base avec des numéros d'ordre corrects (1, 2, 3...). Utilisez l'interface d'administration Django pour vérifier.

### Le disque est plein

Supprimez les fichiers audio en double dans le dossier media/tracks/ et les fichiers temporaires courant.mp3 et alerte.mp3 créés par les lecteurs.

---

## Informations techniques

- Backend : Django 4.2 avec Django REST Framework
- Base de données : MySQL 8.0
- Frontend : React 18 avec Axios
- Audio : pygame 2.6 avec SDL2
- Communication : API REST en JSON, polling toutes les 3 secondes
- Authentification dashboard : login local côté React (maketing / 0000)
- Authentification API : aucune pour le heartbeat, sessions Django pour le reste

