#!/bin/bash
echo " Démarrage de la supervision des gares..."

python player_client_Grenoble.py > grenoble.log 2>&1 &
python player_client_Lyon.py > lyon.log 2>&1 &
python player_client_Sud.py > sud.log 2>&1 &
python player_client.py > nord.log 2>&1 &
echo " Toutes les gares sont actives en arrière-plan !"
