import requests
import time
import pygame
import os
import sys
from datetime import datetime

# ============================================================
# CONFIGURATION — modifier le PLAYER_NAME selon la gare
# ============================================================
PLAYER_NAME        = "Lecteur_Gare_Sud"
API_URL            = "http://127.0.0.1:8000/api/heartbeat/"
FILE_MUSIQUE       = "courant.mp3"
FILE_ALERTE        = "alerte.mp3"
HEARTBEAT_INTERVAL = 3
POST_ALERT_LOCKOUT = 5
DOWNLOAD_TIMEOUT   = 10
# ============================================================


def log(message):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] [{PLAYER_NAME}] {message}", flush=True)


# --- INITIALISATION PYGAME ---
try:
    pygame.mixer.init()
    log("Pygame mixer initialisé.")
except Exception as e:
    log(f"ERREUR init pygame : {e}")
    sys.exit(1)


# Flag pour savoir si on a lancé une lecture (ambiance ou alerte)
en_lecture = [False]


def telecharger_fichier(url, destination):
    try:
        log(f"Téléchargement : {url}")
        resp = requests.get(url, stream=True, timeout=DOWNLOAD_TIMEOUT)
        resp.raise_for_status()
        with open(destination, "wb") as f:
            for chunk in resp.iter_content(chunk_size=8192):
                f.write(chunk)
        log(f"Sauvegardé : {destination}")
        return True
    except Exception as e:
        log(f"ERREUR téléchargement : {e}")
        return False


def jouer_fichier(path, start_pos=0):
    """Joue un fichier UNE SEULE FOIS (pas de boucle)."""
    try:
        pygame.mixer.music.load(path)
        pygame.mixer.music.play(0, start=start_pos)  # 0 = jouer une fois
        en_lecture[0] = True
        log(f"▶️  Lecture : {os.path.basename(path)} (pos={start_pos:.1f}s)")
        return True
    except Exception as e:
        log(f"ERREUR lecture : {e}")
        return False


def envoyer_heartbeat(status, track_id=None):
    try:
        payload = {"name": PLAYER_NAME, "current_track": status}
        if track_id is not None:
            payload["track_id"] = track_id
        r = requests.post(API_URL, json=payload, timeout=5)
        if r.status_code == 200:
            return r.json()
        log(f"Erreur serveur : {r.status_code}")
        return None
    except requests.exceptions.ConnectionError:
        log("Serveur inaccessible.")
        return None
    except requests.exceptions.Timeout:
        log("Timeout serveur.")
        return None
    except Exception as e:
        log(f"Erreur heartbeat : {e}")
        return None


def appliquer_reponse(data, current_url, current_playlist_id, track_id_actuel,
                      is_alert_mode, music_paused_pos, last_alert_end_time):
    if not data:
        return current_url, current_playlist_id, track_id_actuel, is_alert_mode, music_paused_pos, last_alert_end_time

    new_url         = data.get("required_track_url", "")
    is_alert_inc    = data.get("is_alert", False)
    new_vol         = data.get("volume")
    new_playlist_id = data.get("required_playlist_id")
    new_track_id    = data.get("required_track_id")

    # Mise à jour volume
    if new_vol is not None:
        pygame.mixer.music.set_volume(int(new_vol) / 100.0)

    # --- DÉCLENCHEMENT ALERTE ---
    if is_alert_inc and not is_alert_mode:
        log("⚠️  ALERTE — mise en pause de l'ambiance.")
        raw_pos = pygame.mixer.music.get_pos()
        music_paused_pos = (raw_pos / 1000.0) if raw_pos > 0 else 0.0
        pygame.mixer.music.pause()
        en_lecture[0] = False

        if new_url:
            ok = telecharger_fichier(new_url, FILE_ALERTE)
            if ok:
                jouer_fichier(FILE_ALERTE)
                is_alert_mode = True
            else:
                log("Téléchargement alerte échoué — reprise ambiance.")
                pygame.mixer.music.unpause()
                en_lecture[0] = True
        else:
            log("Alerte sans URL — ignorée.")
            pygame.mixer.music.unpause()
            en_lecture[0] = True

    # --- MODE NORMAL : nouveau morceau ou morceau suivant ---
    elif not is_alert_mode and new_url:
        temps_depuis_alerte = time.time() - last_alert_end_time
        morceau_different   = new_url != current_url
        playlist_differente = new_playlist_id != current_playlist_id

        if morceau_different or playlist_differente:
            if temps_depuis_alerte >= POST_ALERT_LOCKOUT:
                log(f"🎵 Morceau : {data.get('required_track_name')} (id={new_track_id})")
                ok = telecharger_fichier(new_url, FILE_MUSIQUE)
                if ok:
                    jouer_fichier(FILE_MUSIQUE)
                    current_url         = new_url
                    current_playlist_id = new_playlist_id
                    track_id_actuel     = new_track_id
                else:
                    log("Impossible de charger le morceau.")
            else:
                log(f"Lockout post-alerte ({temps_depuis_alerte:.1f}s) — ignoré.")

    # --- ARRÊT DEMANDÉ ---
    elif not is_alert_mode and not new_url and current_url:
        log("🛑 Arrêt demandé par le serveur.")
        pygame.mixer.music.stop()
        en_lecture[0]       = False
        current_url         = None
        current_playlist_id = None
        track_id_actuel     = None

    return current_url, current_playlist_id, track_id_actuel, is_alert_mode, music_paused_pos, last_alert_end_time


# ============================================================
# ÉTAT INITIAL
# ============================================================
current_url         = None
current_playlist_id = None
track_id_actuel     = None
is_alert_mode       = False
music_paused_pos    = 0.0
last_alert_end_time = 0.0
dernier_heartbeat   = 0.0

log("=== Démarrage ===")

while True:
    try:
        maintenant = time.time()
        is_playing  = pygame.mixer.music.get_busy()

        # --------------------------------------------------------
        # CAS 1 : Fin de morceau d'ambiance détectée
        # en_lecture passe à True quand on joue, False quand pygame s'arrête
        # --------------------------------------------------------
        if not is_playing and en_lecture[0] and not is_alert_mode:
            log("🔚 Fin de morceau — demande du suivant.")
            en_lecture[0] = False
            data = envoyer_heartbeat("IDLE", track_id=track_id_actuel)
            current_url, current_playlist_id, track_id_actuel, is_alert_mode, music_paused_pos, last_alert_end_time = \
                appliquer_reponse(data, current_url, current_playlist_id, track_id_actuel,
                                  is_alert_mode, music_paused_pos, last_alert_end_time)
            dernier_heartbeat = maintenant

        # --------------------------------------------------------
        # CAS 2 : Fin d'alerte détectée
        # --------------------------------------------------------
        elif not is_playing and en_lecture[0] and is_alert_mode:
            log("🔔 Alerte terminée — reprise de l'ambiance.")
            en_lecture[0]       = False
            is_alert_mode       = False
            last_alert_end_time = time.time()
            if os.path.exists(FILE_MUSIQUE):
                jouer_fichier(FILE_MUSIQUE, start_pos=music_paused_pos)
            else:
                log("Fichier ambiance introuvable — attente heartbeat.")
            dernier_heartbeat = maintenant

        # --------------------------------------------------------
        # CAS 3 : Heartbeat périodique
        # Suspendu pendant une alerte en cours de lecture
        # --------------------------------------------------------
        elif maintenant - dernier_heartbeat >= HEARTBEAT_INTERVAL:
            if is_alert_mode and is_playing:
                # Ne pas interrompre l'alerte
                dernier_heartbeat = maintenant
            else:
                status = "PLAYING" if is_playing else "IDLE"
                data = envoyer_heartbeat(status, track_id=track_id_actuel)
                current_url, current_playlist_id, track_id_actuel, is_alert_mode, music_paused_pos, last_alert_end_time = \
                    appliquer_reponse(data, current_url, current_playlist_id, track_id_actuel,
                                      is_alert_mode, music_paused_pos, last_alert_end_time)
                dernier_heartbeat = maintenant

        # Boucle rapide pour détecter fin de morceau instantanément
        time.sleep(0.3)

    except KeyboardInterrupt:
        log("Arrêt manuel.")
        pygame.mixer.music.stop()
        pygame.mixer.quit()
        sys.exit(0)

    except Exception as e:
        log(f"ERREUR inattendue : {e}")
        time.sleep(3)
