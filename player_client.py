import requests
import time
import pygame
import os
import sys
from datetime import datetime

# --- CONFIGURATION ---
API_URL = "http://127.0.0.1:8000/api/heartbeat/"
PLAYER_NAME = sys.argv[1] if len(sys.argv) > 1 else "Lecteur_Gare_nord"
TEMP_FILE = f"audio_{PLAYER_NAME}.mp3"
TEMP_ALERT_FILE = f"alert_{PLAYER_NAME}.mp3"

def log(message, level="INFO"):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    icons = {"INFO": "🔹", "SUCCESS": "✅", "UPDATE": "", "WARN": "⚠️", "ERROR": "❌", "MUSIC": "🎵", "STOP": "🛑", "TIME": "⏱️", "ALERT": "🚨"}
    print(f"[{timestamp}] {icons.get(level, '🔹')} {message}")

# --- INITIALISATION ---
pygame.mixer.init()
current_url = None
derniere_alerte_url = None # <--- Pour mémoriser l'alerte passée
current_vol = -1
alerte_active = False  

log(f"Démarrage du lecteur : {PLAYER_NAME}", "INFO")

try:
    while True:
        try:
            is_playing = pygame.mixer.music.get_busy()
            status = "Lecture en cours" if is_playing else "Arrêté"

            # 1. Ping vers Django
            payload = {"name": PLAYER_NAME, "track": status}
            r = requests.post(API_URL, json=payload, timeout=5)

            if r.status_code == 200:
                cmd = r.json()
                new_url = cmd.get("required_track_url")
                new_name = cmd.get("required_track_name")
                is_alert = cmd.get("is_alert", False)
                new_vol = int(cmd.get("volume", 50))

                # --- GESTION DU VOLUME ---
                if new_vol != current_vol:
                    pygame.mixer.music.set_volume(new_vol / 100.0)
                    log(f"Volume : {new_vol}%", "UPDATE")
                    current_vol = new_vol

                # --- LOGIQUE D'ALERTE (PRIORITAIRE) ---
                if is_alert:
                    if not alerte_active:
                        log(f"🚨 ALERTE DÉTECTÉE : {new_name}", "ALERT")
                        
                        # Memoriser la position pour la reprise
                        pos_reprise = pygame.mixer.music.get_pos() / 1000.0 if is_playing else 0
                        
                        log("Téléchargement de l'alerte...", "INFO")
                        resp = requests.get(new_url)
                        with open(TEMP_ALERT_FILE, "wb") as f:
                            f.write(resp.content)
                        
                        pygame.mixer.music.load(TEMP_ALERT_FILE)
                        pygame.mixer.music.play(0) 
                        
                        alerte_active = True
                        derniere_alerte_url = new_url # <--- On stocke l'URL de l'alerte
                        
                        while pygame.mixer.music.get_busy():
                            time.sleep(0.5)
                        
                        log("Fin de l'alerte, reprise de l'ambiance", "SUCCESS")
                        
                        if os.path.exists(TEMP_FILE):
                            pygame.mixer.music.load(TEMP_FILE)
                            pygame.mixer.music.play(-1, start=pos_reprise)
                        
                        alerte_active = False 
                
                # --- LOGIQUE D'AMBIANCE NORMALE ---
                elif new_url and new_url != current_url and not alerte_active:
                    
                    # SÉCURITÉ : On vérifie si new_url n'est pas l'alerte qu'on vient de finir
                    if new_url == derniere_alerte_url:
                        # C'est l'alerte qui traîne encore dans la réponse du serveur, on ignore.
                        pass
                    else:
                        log(f"Changement d'ambiance : {new_name}", "MUSIC")
                        
                        with requests.get(new_url, stream=True) as stream:
                            with open(TEMP_FILE, "wb") as f:
                                for chunk in stream.iter_content(8192):
                                    f.write(chunk)
                        
                        pygame.mixer.music.load(TEMP_FILE)
                        pygame.mixer.music.play(-1)
                        current_url = new_url
                        derniere_alerte_url = None # On réinitialise car on a une vraie nouvelle musique

                # CAS : Arrêt total
                elif not new_url and current_url and not alerte_active:
                    pygame.mixer.music.stop()
                    current_url = None
                    derniere_alerte_url = None
                    log("Musique coupée (Dashboard)", "STOP")

            else:
                log(f"Erreur API : {r.status_code}", "ERROR")

        except Exception as e:
            log(f"Erreur : {e}", "ERROR")

        time.sleep(2) 

except KeyboardInterrupt:
    log("Arrêt utilisateur", "WARN")
finally:
    pygame.mixer.quit()
