import subprocess
import time
import sys

LECTEURS = ["Lecteur_Gare_Nord", "Lecteur_Gare_Sud", "Lecteur_Gare_Grenoble", "Lecteur_Gare_Nante"]
SCRIPT = "player_client.py"

procs = []

for nom in LECTEURS:
    # On lance le même script, mais avec un nom différent en argument
    p = subprocess.Popen([sys.executable, SCRIPT, nom])
    procs.append(p)
    print(f"🚀 Lancé : {nom}")
    time.sleep(1)

try:
    while True: time.sleep(1)
except KeyboardInterrupt:
    for p in procs: p.terminate()
