import requests
import time
import pygame
import os

# --- CONFIGURATION ---
API_URL = "http://127.0.0.1:8000/api/heartbeat/"
PLAYER_NAME = "Lecteur_Gare_Grenoble"
TEMP_FILE = f"audio_{PLAYER_NAME}.mp3"

# --- INITIALISATION ---
pygame.mixer.init()
current_url = None
current_vol = -1 

print(f"🚀 Démarrage du lecteur : {PLAYER_NAME}")

try:
    while True:
        try:
            # 1. Vérification de l'état actuel de lecture
            is_playing = pygame.mixer.music.get_busy()
            status = "Lecture en cours" if is_playing else "Arrêté"

            # 2. Envoi du Ping au serveur (Timeout de 5s pour la stabilité)
            payload = {"name": PLAYER_NAME, "track": status}
            r = requests.post(API_URL, json=payload, timeout=5)
            
            if r.status_code == 200:
                cmd = r.json()
                
                # --- GESTION DU VOLUME ---
                new_vol = int(cmd.get('volume', 50))
                if new_vol != current_vol:
                    pygame.mixer.music.set_volume(new_vol / 100.0)
                    print(f"🔊 Volume : {new_vol}%")
                    current_vol = new_vol

                # --- GESTION DE LA MUSIQUE ---
                new_url = cmd.get('required_track_url')
                new_name = cmd.get('required_track_name', 'Inconnu')

                # CAS 1 : Nouvelle piste détectée
                if new_url and new_url != current_url:
                    print(f"🎵 Changement de piste : {new_name}")
                    
                    pygame.mixer.music.stop()
                    pygame.mixer.music.unload() 

                    # Téléchargement par flux (Stream)
                    with requests.get(new_url, stream=True) as stream:
                        with open(TEMP_FILE, 'wb') as f:
                            for chunk in stream.iter_content(8192):
                                if chunk: f.write(chunk)
                    
                    pygame.mixer.music.load(TEMP_FILE)
                    pygame.mixer.music.play(-1) # Lecture en boucle
                    current_url = new_url
                    print(f"▶️ En lecture : {new_name}")

                # CAS 2 : Relance si la musique s'est coupée par erreur
                elif new_url and not is_playing:
                    pygame.mixer.music.play(-1)
                    print("🔄 Relance automatique de la lecture")

                # CAS 3 : Arrêt demandé par le serveur (URL vide)
                elif not new_url and current_url:
                    pygame.mixer.music.stop()
                    current_url = None
                    print("🛑 Arrêt ordonné par le dashboard")

        except requests.exceptions.RequestException:
            print("⚠️ Erreur : Liaison perdue avec le serveur...")
        except Exception as e:
            print(f"⚠️ Erreur système : {e}")

        # Pause entre deux vérifications
        time.sleep(3)

except KeyboardInterrupt:
    print("\n\n🛑 Arrêt manuel détecté...")
finally:
    pygame.mixer.music.stop()
    pygame.mixer.quit()
    print("👋 Lecteur fermé proprement.")
