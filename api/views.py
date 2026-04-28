from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.utils import timezone
from django.utils.timezone import localtime
from datetime import timedelta
from .models import Player, Track

@api_view(['GET'])
def dashboard(request):
    """ Envoie les données au Dashboard React """
    try:
        players = Player.objects.all()
        tracks = Track.objects.all()
        
        # Tolérance de 30 secondes pour éviter le clignotement ONLINE/OFFLINE
        threshold = timezone.now() - timedelta(seconds=5)
        
        player_data = []
        for p in players:
            # Vérification de l'état de connexion
            is_online = p.last_ping and p.last_ping > threshold
            
            # Formatage de l'heure du dernier ping
            last_ping_display = localtime(p.last_ping).strftime("%H:%M:%S") if p.last_ping else "Jamais"
            
            player_data.append({
                "name": p.name,
                "status": "ONLINE" if is_online else "OFFLINE",
                "last_ping": last_ping_display,
                # On affiche le statut réel du lecteur (s'il est online)
                "current_track": p.current_track if is_online else "Déconnecté",
                "volume": p.volume,
                "required_track_id": p.required_track.id if p.required_track else None
            })

        return Response({
            "players": player_data,
            "available_tracks": [{"id": t.id, "title": t.title} for t in tracks]
        })
    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['POST'])
def heartbeat(request):
    """ Centralise les pings des lecteurs et les ordres du Dashboard """
    try:
        data = request.data
        name = data.get('name')
        
        if not name:
            return Response({"error": "Nom du lecteur manquant"}, status=400)

        # Récupération ou création du lecteur
        player, _ = Player.objects.get_or_create(name=name)
        player.last_ping = timezone.now()
        
        # 1. Mise à jour du statut renvoyé par le script Python
        if 'track' in data:
            player.current_track = data.get('track')
        
        # 2. Mise à jour de la commande de musique venant de React
        if 'track_id' in data:
            tid = data.get('track_id')
            player.required_track = Track.objects.filter(id=tid).first() if tid else None
        
        # 3. Mise à jour de la commande de volume venant de React
        if 'volume' in data:
            try:
                player.volume = int(data.get('volume'))
            except (ValueError, TypeError):
                pass
            
        player.save()
        
        # 4. Préparation de la réponse pour le lecteur Python
        track_url = ""
        track_name = ""
        
        if player.required_track:
            track_name = player.required_track.title
            if player.required_track.audio_file:
                # Génère l'URL absolue (http://...) du fichier MP3
                track_url = request.build_absolute_uri(player.required_track.audio_file.url)

        return Response({
            "status": "success",
            "required_track_url": track_url,
            "required_track_name": track_name,
            "volume": player.volume
        })
        
    except Exception as e:
        return Response({"error": str(e)}, status=500)
