import requests
import time
import pygame
import os
from datetime import datetime

# --- CONFIGURATION ---
API_URL = "http://127.0.0.1:8000/api/heartbeat/"
PLAYER_NAME = "Lecteur_Gare_Grenoble"
TEMP_FILE = f"audio_{PLAYER_NAME}.mp3"

# --- UTILITAIRES DE TRAÇABILITÉ ---
def log(message, level="INFO"):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    icons = {
        "INFO": "",
        "SUCCESS": "✅",
        "UPDATE": "🔄",
        "WARN": "⚠️",
        "ERROR": "❌",
        "MUSIC": "🎵",
        "STOP": "🛑",
        "TIME": "⏱️"
    }
    print(f"[{timestamp}] {icons.get(level, '🔹')} {message}")

# --- INITIALISATION ---
pygame.mixer.init()

current_url = None
current_vol = -1
ping_count = 0
stop_timer = None  # Timer pour arrêt automatique après 30 secondes d'inactivité

log(f"Initialisation du lecteur système : {PLAYER_NAME}", "INFO")
log(f"Cible API : {API_URL}", "INFO")

try:
    while True:
        try:
            # 1. État actuel du lecteur
            is_playing = pygame.mixer.music.get_busy()
            status = "Lecture en cours" if is_playing else "Arrêté"

            # 2. Arrêt automatique après 30 secondes d'inactivité
            if not is_playing:
                if stop_timer is None:
                    stop_timer = time.time()
                elif time.time() - stop_timer >= 30:
                    log("Inactivité de 30s détectée. Arrêt automatique du serveur.", "TIME")
                    break
            else:
                stop_timer = None

            # 3. Communication avec le serveur
            payload = {
                "name": PLAYER_NAME,
                "track": status
            }

            r = requests.post(API_URL, json=payload, timeout=5)

            if r.status_code == 200:
                cmd = r.json()
                ping_count += 1

                if ping_count % 5 == 0:
                    log(f"Liaison serveur active (Ping #{ping_count})", "INFO")

                # --- VOLUME ---
                new_vol = int(cmd.get("volume", 50))

                if new_vol != current_vol:
                    pygame.mixer.music.set_volume(new_vol / 100.0)
                    log(f"Volume système modifié : {new_vol}%", "UPDATE")
                    current_vol = new_vol

                # --- MUSIQUE ---
                new_url = cmd.get("required_track_url")
                new_name = cmd.get("required_track_name", "Inconnu")

                # CAS 1 : Nouvelle musique demandée
                if new_url and new_url != current_url:
                    log(f"Nouvelle instruction reçue : {new_name}", "MUSIC")

                    pygame.mixer.music.stop()
                    pygame.mixer.music.unload()

                    log(f"Téléchargement du flux : {new_url[:40]}...", "INFO")

                    with requests.get(new_url, stream=True) as stream:
                        stream.raise_for_status()

                        with open(TEMP_FILE, "wb") as f:
                            for chunk in stream.iter_content(8192):
                                if chunk:
                                    f.write(chunk)

                    pygame.mixer.music.load(TEMP_FILE)
                    pygame.mixer.music.play(-1)

                    current_url = new_url
                    stop_timer = None

                    log(f"Signal envoyé démarrage de la lecture : {new_name}", "SUCCESS")

                # CAS 2 : Auto-réparation de la lecture
                elif new_url and current_url and not is_playing:
                    pygame.mixer.music.play(-1)
                    stop_timer = None
                    log(f"Restauration automatique du flux audio : {new_name}", "WARN")

                # CAS 3 : Arrêt distant depuis le Dashboard
                elif not new_url and current_url:
                    pygame.mixer.music.stop()
                    pygame.mixer.music.unload()
                    current_url = None
                    stop_timer = time.time()

                    log("Arrêt à distance reçu du Dashboard.", "STOP")

            else:
                log(f"Réponse serveur anormale (Code: {r.status_code})", "ERROR")

        except requests.exceptions.RequestException:
            log("Serveur injoignable (Tentative de reconnexion...)", "WARN")

        except Exception as e:
            log(f"Erreur système critique : {e}", "ERROR")

        time.sleep(3)

except KeyboardInterrupt:
    log("Interruption manuelle (KeyboardInterrupt)", "WARN")

finally:
    pygame.mixer.music.stop()
    pygame.mixer.quit()

    if os.path.exists(TEMP_FILE):
        try:
            os.remove(TEMP_FILE)
        except Exception:
            pass

    log("Système éteint.", "STOP")
