from rest_framework.decorators import api_view
from rest_framework.response import Response
from .models import Player, Track
from django.utils import timezone
from datetime import timedelta
from django.utils.timezone import localtime

@api_view(['GET'])
def dashboard(request):
    """ Envoie les données au Dashboard React """
    try:
        players = Player.objects.all()
        tracks = Track.objects.all()
        # On considère ONLINE si ping < 5 secondes
        threshold = timezone.now() - timedelta(seconds=3)
        
        data = []
        for p in players:
            is_online = p.last_ping and p.last_ping > threshold
            # Utilise localtime() configuré sur Europe/Paris dans tes settings
            last_ping_display = localtime(p.last_ping).strftime("%H:%M:%S") if p.last_ping else "Jamais"
            
            data.append({
                "name": p.name,
                "status": "ONLINE" if is_online else "OFFLINE",
                "last_ping": last_ping_display,
                "current_track": p.current_track if is_online else "Arrêté",
                "volume": p.volume,
                "required_track_id": p.required_track.id if p.required_track else None
            })

        return Response({
            "players": data,
            "available_tracks": [{"id": t.id, "title": t.title} for t in tracks]
        })
    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['POST'])
def heartbeat(request):
    """ Reçoit les pings des lecteurs Python et les ordres du Dashboard """
    try:
        name = request.data.get('name')
        if not name:
            return Response({"error": "Nom du lecteur manquant"}, status=400)

        player, _ = Player.objects.get_or_create(name=name)
        player.last_ping = timezone.now()
        
        # Si le lecteur nous dit ce qu'il joue
        if 'track' in request.data:
            player.current_track = request.data.get('track')
        
        # Si React envoie une commande de musique
        if 'track_id' in request.data:
            tid = request.data.get('track_id')
            player.required_track = Track.objects.filter(id=tid).first() if tid else None
        
        # Si React envoie une commande de volume
        if 'volume' in request.data:
            player.volume = int(request.data.get('volume'))
            
        player.save()
        
        # On construit l'URL complète pour le téléchargement
        url = ""
        if player.required_track and player.required_track.audio_file:
            url = request.build_absolute_uri(player.required_track.audio_file.url)

        return Response({
            "status": "success",
            "required_track_url": url,
            "required_track_name": player.required_track.title if player.required_track else "",
            "volume": player.volume
        })
    except Exception as e:
        return Response({"error": str(e)}, status=500)
