import requests
import time
import pygame
import os
from datetime import datetime

# --- CONFIGURATION ---
API_URL = "http://127.0.0.1:8000/api/heartbeat/"
PLAYER_NAME = "Lecteur_Gare_Sud"
TEMP_FILE = f"audio_{PLAYER_NAME}.mp3"

# --- UTILITAIRES DE TRAÇABILITÉ ---
def log(message, level="INFO"):
    """ Affiche un log horodaté et stylisé dans le terminal """
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    icons = {"INFO": "ℹ️", "SUCCESS": "✅", "UPDATE": "🔄", "WARN": "⚠️", "ERROR": "❌", "MUSIC": "🎵"}
    print(f"[{timestamp}] {icons.get(level, '🔹')} {message}")

# --- INITIALISATION ---
pygame.mixer.init()
current_url = None
current_vol = -1 
ping_count = 0

log(f"Initialisation du lecteur système : {PLAYER_NAME}", "INFO")
log(f"Cible API : {API_URL}", "INFO")

try:
    while True:
        try:
            # 1. Analyse de l'état actuel
            is_playing = pygame.mixer.music.get_busy()
            status = "Lecture en cours" if is_playing else "Arrêté"

            # 2. Communication avec le serveur
            payload = {"name": PLAYER_NAME, "track": status}
            r = requests.post(API_URL, json=payload, timeout=5)
            
            if r.status_code == 200:
                cmd = r.json()
                ping_count += 1
                
                # Petit indicateur de vie silencieux (tous les 5 pings)
                if ping_count % 5 == 0:
                    log(f"Liaison serveur active (Ping #{ping_count})", "INFO")

                # --- TRAÇABILITÉ DU VOLUME ---
                new_vol = int(cmd.get('volume', 50))
                if new_vol != current_vol:
                    pygame.mixer.music.set_volume(new_vol / 100.0)
                    log(f"Volume système modifié : {new_vol}%", "UPDATE")
                    current_vol = new_vol

                # --- TRAÇABILITÉ DE LA MUSIQUE ---
                new_url = cmd.get('required_track_url')
                new_name = cmd.get('required_track_name', 'Inconnu')

                # CAS 1 : Changement de flux audio
                if new_url and new_url != current_url:
                    log(f"Nouvelle instruction reçue : {new_name}", "MUSIC")
                    
                    pygame.mixer.music.stop()
                    pygame.mixer.music.unload() 

                    log(f"Téléchargement du flux : {new_url[:40]}...", "INFO")
                    with requests.get(new_url, stream=True) as stream:
                        with open(TEMP_FILE, 'wb') as f:
                            for chunk in stream.iter_content(8192):
                                if chunk: f.write(chunk)
                    
                    pygame.mixer.music.load(TEMP_FILE)
                    pygame.mixer.music.play(-1)
                    current_url = new_url
                    log(f"Signal envoyé démarrage de la lecture : {new_name}", "SUCCESS")

                # CAS 2 : Auto-réparation de la lecture
                elif new_url and not is_playing:
                    pygame.mixer.music.play(-1)
                    log(f"Restauration automatique du flux audio : {new_name}", "WARN")

                # CAS 3 : Arrêt distant
                elif not new_url and current_url:
                    pygame.mixer.music.stop()
                    current_url = None
                    log("Commande d'arrêt reçue du Dashboard", "UPDATE")

            else:
                log(f"Réponse serveur anormale (Code: {r.status_code})", "ERROR")

        except requests.exceptions.RequestException as e:
            log(f"Serveur injoignable (Tentative de reconnexion...)", "WARN")
        except Exception as e:
            log(f"Erreur système critique : {e}", "ERROR")

        time.sleep(3)

except KeyboardInterrupt:
    log("Interruption manuelle (KeyboardInterrupt)", "WARN")
finally:
    pygame.mixer.music.stop()
    pygame.mixer.quit()
    log("Processus terminé. Lecteur déconnecté.", "INFO")
