import requests
import time
import pygame
import os
import sys
from datetime import datetime

# --- CONFIGURATION DYNAMIQUE ---
API_URL = "http://127.0.0.1:8000/api/heartbeat/"

# RÉCUPÉRATION DU NOM DEPUIS LE LAUNCHER
# Si on lance "python player_client.py Gare_Nord", sys.argv[1] sera "Gare_Nord"
if len(sys.argv) > 1:
    PLAYER_NAME = sys.argv[1]
else:
    PLAYER_NAME = "Lecteur_Standard"

# FICHIER TEMP UNIQUE : Crucial pour éviter que les gares ne se bloquent entre elles
TEMP_FILE = f"audio_cache_{PLAYER_NAME}.mp3"

# --- UTILITAIRES ---
def log(message, level="INFO"):
    timestamp = datetime.now().strftime("%H:%M:%S")
    icons = {"INFO": "🔹", "SUCCESS": "✅", "UPDATE": "🔄", "WARN": "⚠️", "ERROR": "❌", "MUSIC": "🎵", "STOP": "🛑"}
    print(f"[{timestamp}] [{PLAYER_NAME}] {icons.get(level, '🔹')} {message}")

# --- INITIALISATION ---
pygame.mixer.init()
current_url = None
current_vol = -1
ping_count = 0

log(f"Démarrage du système...", "INFO")

try:
    while True:
        try:
            # 1. État actuel
            is_playing = pygame.mixer.music.get_busy()
            status = "Lecture en cours" if is_playing else "En attente"

            # 2. Envoi du Heartbeat à Django
            payload = {
                "name": PLAYER_NAME,
                "track": status,
                "volume": current_vol if current_vol != -1 else 50
            }

            r = requests.post(API_URL, json=payload, timeout=5)

            if r.status_code == 200:
                cmd = r.json()
                ping_count += 1

                # Log toutes les 5 itérations pour ne pas polluer le terminal
                if ping_count % 5 == 0:
                    log(f"Liaison active - Statut: {status}", "INFO")

                # --- GESTION DU VOLUME ---
                new_vol = int(cmd.get("volume", 50))
                if new_vol != current_vol:
                    pygame.mixer.music.set_volume(new_vol / 100.0)
                    log(f"Volume mis à jour : {new_vol}%", "UPDATE")
                    current_vol = new_vol

                # --- GESTION DE LA MUSIQUE ---
                new_url = cmd.get("required_track_url")
                new_name = cmd.get("required_track_name", "Inconnu")

                # Cas : Nouvelle musique ou changement de piste
                if new_url and new_url != current_url:
                    log(f"Nouvelle piste détectée : {new_name}", "MUSIC")
                    
                    pygame.mixer.music.stop()
                    pygame.mixer.music.unload()

                    # Téléchargement sécurisé
                    with requests.get(new_url, stream=True) as stream:
                        stream.raise_for_status()
                        with open(TEMP_FILE, "wb") as f:
                            for chunk in stream.iter_content(8192):
                                f.write(chunk)

                    pygame.mixer.music.load(TEMP_FILE)
                    pygame.mixer.music.play(-1) # Boucle infinie
                    current_url = new_url
                    log(f"Lecture lancée : {new_name}", "SUCCESS")

                # Cas : Arrêt demandé par le Dashboard
                elif not new_url and current_url:
                    pygame.mixer.music.stop()
                    pygame.mixer.music.unload()
                    current_url = None
                    log("Arrêt de la musique demandé par le serveur", "STOP")

                # Cas : Auto-restauration si la musique s'arrête par erreur
                elif new_url and not is_playing:
                    pygame.mixer.music.play(-1)
                    log("Restauration de la lecture", "WARN")

            else:
                log(f"Erreur API ({r.status_code})", "ERROR")

        except requests.exceptions.RequestException:
            log("Serveur distant injoignable...", "WARN")
        except Exception as e:
            log(f"Erreur : {e}", "ERROR")

        time.sleep(3) # Intervalle de 3 secondes entre chaque check

except KeyboardInterrupt:
    log("Arrêt manuel détecté", "WARN")

finally:
    pygame.mixer.music.stop()
    pygame.mixer.quit()
    # Nettoyage du fichier propre à ce lecteur
    if os.path.exists(TEMP_FILE):
        try:
            os.remove(TEMP_FILE)
        except:
            pass
    log("Lecteur éteint proprement.", "STOP")
