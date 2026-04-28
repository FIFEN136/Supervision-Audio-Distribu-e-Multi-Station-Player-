Supervision Audio Distribuée (Multi-Station Player)
Ce projet permet de piloter à distance une flotte de lecteurs audio (Raspberry Pi, PC, serveurs locaux) via un tableau de bord centralisé en temps réel. Chaque lecteur (gare, magasin, salle) reçoit ses instructions (piste à jouer, volume) via une API Django.

🏗️ Architecture du Système
Le projet repose sur trois piliers technologiques :

Backend (Django + REST Framework) : Le cerveau du système. Il gère la base de données, les pistes audio disponibles et l'état de chaque lecteur.

Dashboard (React + Axios) : L'interface de contrôle. Elle affiche l'état des lecteurs (point vert/rouge) et permet d'envoyer des ordres de changement de volume ou de musique.

Lecteur Local (Python + Pygame) : Le client installé sur chaque point de diffusion. Il "ping" le serveur, télécharge la musique si nécessaire et gère la lecture sonore.

🚀 Fonctionnalités
Monitoring Temps Réel : Visualisation du statut (Online/Offline) avec des indicateurs colorés stables.

Contrôle du Volume : Réglage individuel par lecteur avec mise à jour immédiate.

Gestion de Playlist : Sélection de pistes audio centralisée sur le serveur.

Auto-Relance : Redémarrage automatique de la lecture en cas de micro-coupure réseau ou erreur locale.

Mode Optimiste : L'interface React réagit instantanément aux changements avant même la confirmation du serveur pour une meilleure fluidité.

🛠️ Installation
1. Serveur Django
Bash
cd backend
pip install django djangorestframework django-cors-headers
python manage.py migrate
python manage.py runserver
2. Dashboard React
Bash
cd frontend
npm install axios
npm start
3. Lecteur Python (Client)
Répétez cette opération pour chaque station en changeant le PLAYER_NAME dans le script.

Bash
pip install requests pygame
python lecteur.py
📁 Structure des fichiers
Plaintext
├── backend/
│   ├── db.sqlite3          # Base de données (Pistes, Lecteurs, Logs)
│   ├── api/                # Logique REST (Heartbeat, Dashboard)
│   └── media/              # Stockage des fichiers MP3
├── frontend/
│   ├── src/
│   │   ├── App.js          # Logique React (Auto-refresh 3s, useCallback)
│   │   └── App.css         # Design sombre, Glassmorphism et Status Dots
├── lecteurs/
│   └── lecteur_nord.py     # Script client Python (Pygame + Requests)
└── README.md
⚙️ Configuration du Client Python
Chaque client possède son propre identifiant unique. Modifiez les variables en haut du script lecteur.py :

Python
API_URL = "http://[IP_DU_SERVEUR]:8000/api/heartbeat/"
PLAYER_NAME = "Gare_de_Lyon"  # Nom unique affiché sur le Dashboard
🎨 Guide des Statuts Visuels
🟢 Vert Stable : Le lecteur est connecté et une musique est en cours de lecture.

🔴 Rouge Stable : Le lecteur est déconnecté (pas de ping depuis > 30s) ou la lecture est arrêtée.

🔊 Volume : Affiché en pourcentage, mis à jour dynamiquement toutes les 5 secondes.
