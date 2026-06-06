import subprocess
import sys
import signal
import time

# Liste des fichiers à lancer
lecteurs = [
    "player_client_Grenoble.py",
    "player_client_Lyon.py",
    "player_client.py", # Assure-toi que ce fichier contient PLAYER_NAME = "Lecteur_Gare_nord"
    "player_client_Sud.py"
]

processes = []

def arreter_tout(signum, frame):
    print("\n[MAÎTRE] Arrêt demandé. Fermeture de tous les lecteurs...")
    for p in processes:
        p.terminate()
    sys.exit(0)

# Intercepter le Ctrl+C
signal.signal(signal.SIGINT, arreter_tout)

def lancer():
    print(f"=== Démarrage groupé de {len(lecteurs)} lecteurs ===")
    for script in lecteurs:
        try:
            # On lance chaque script avec l'interpréteur Python actif
            p = subprocess.Popen([sys.executable, script])
            processes.append(p)
            print(f"[MAÎTRE] {script} lancé (PID: {p.pid})")
        except Exception as e:
            print(f"[ERREUR] Impossible de lancer {script} : {e}")

    print("=== Tous les lecteurs tournent. Appuyez sur Ctrl+C pour arrêter tout. ===")
    
    # Boucle principale pour maintenir le script maître en vie
    while True:
        time.sleep(1)

if __name__ == "__main__":
    lancer()
