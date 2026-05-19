from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.utils import timezone
from django.utils.timezone import localtime
from datetime import timedelta
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
import json
from .models import Player, Track, ScheduledAlert

@api_view(['GET'])
def dashboard(request):
    """ Envoie les données au Dashboard React """
    try:
        players = Player.objects.all()
        tracks = Track.objects.all()
        
        threshold = timezone.now() - timedelta(seconds=10)
        
        player_data = []
        for p in players:
            is_online = p.last_ping and p.last_ping > threshold
            last_ping_display = localtime(p.last_ping).strftime("%H:%M:%S") if p.last_ping else "Jamais"
            
            player_data.append({
                "name": p.name,
                "status": "ONLINE" if is_online else "OFFLINE",
                "last_ping": last_ping_display,
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
    """ Version Finale : Verrouillage strict de l'alerte par minute """
    try:
        data = request.data
        name = data.get('name')
        if not name:
            return Response({"error": "Nom manquant"}, status=400)
            
        player, _ = Player.objects.get_or_create(name=name)
        player.last_ping = timezone.now()
        
        maintenant = localtime(timezone.now())
        jours_fr = {'Monday': 'Lundi', 'Tuesday': 'Mardi', 'Wednesday': 'Mercredi', 'Thursday': 'Jeudi', 'Friday': 'Vendredi', 'Saturday': 'Samedi', 'Sunday': 'Dimanche'}
        jour_fr = jours_fr.get(maintenant.strftime('%A'), 'Lundi')
        minute_cle = maintenant.strftime('%H:%M')
        
        # Identifiant unique pour CETTE alerte précise (ex: ALERTE_Lundi_14:30)
        id_alerte_actuelle = f"ALERTE_{jour_fr}_{minute_cle}"

        # 1. On cherche si une alerte est programmée maintenant
        alerte = ScheduledAlert.objects.filter(
            is_active=True, day=jour_fr, 
            time__hour=maintenant.hour, time__minute=maintenant.minute,
            site__in=[name, "Toutes les gares"]
        ).first()

        is_alert_mode = False

        if alerte:
            # SI le joueur n'a pas encore ce verrou précis, on déclenche
            if player.current_track != id_alerte_actuelle:
                print(f"🔥 DECLENCHEMENT UNIQUE ALERTE : {alerte.track.title}")
                is_alert_mode = True
                player.required_track = alerte.track
                player.volume = alerte.volume
                # On pose le verrou IMMEDIATEMENT
                player.current_track = id_alerte_actuelle 
            else:
                # L'alerte a déjà été envoyée durant cette minute. 
                # On force is_alert à False pour que le script Python ne boucle pas.
                is_alert_mode = False
        else:
            # 2. PAS D'ALERTE : On nettoie le verrou si nécessaire
            if player.current_track and player.current_track.startswith("ALERTE_"):
                print("🔄 FIN DE LA MINUTE D'ALERTE : Retour au mode IDLE")
                player.current_track = "IDLE" 
            
            # Gestion manuelle Dashboard (uniquement si pas d'alerte en cours)
            if 'track_id' in data:
                tid = data.get('track_id')
                player.required_track = Track.objects.filter(id=tid).first() if tid else None
            
            if 'volume' in data:
                try: 
                    player.volume = int(data.get('volume'))
                except: 
                    pass

        player.save()
        
        track_url = ""
        track_name = ""
        if player.required_track:
            track_name = player.required_track.title
            if player.required_track.audio_file:
                track_url = request.build_absolute_uri(player.required_track.audio_file.url)
        
        return Response({
            "status": "success",
            "required_track_url": track_url,
            "required_track_name": track_name,
            "volume": player.volume,
            "is_alert": is_alert_mode
        })
    except Exception as e:
        print(f"Erreur heartbeat: {e}")
        return Response({"error": str(e)}, status=500)

@api_view(['POST'])
def sync_all_players(request):
    try:
        track_id = request.data.get('track_id')
        track = Track.objects.filter(id=track_id).first() if track_id else None
        Player.objects.all().update(required_track=track)
        return Response({"status": "success"})
    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['POST'])
def schedule_alert(request):
    try:
        data = request.data
        track = Track.objects.filter(id=data.get('track_id')).first()
        if not track: return Response({"error": "Son introuvable"}, status=400)
        
        volume_raw = data.get('volume', 50)
        try:
            volume = int(str(volume_raw).replace('%','').strip())
        except:
            volume = 50

        ScheduledAlert.objects.create(
            day=data.get('day'), time=data.get('time'),
            site=data.get('site'), track=track,
            volume=volume,
            is_active=True
        )
        return Response({"status": "success"})
    except Exception as e:
        return Response({"error": str(e)}, status=500)

@api_view(['GET'])
def get_scheduled_alerts(request):
    try:
        alerts = ScheduledAlert.objects.all().order_by('time')
        data = [{"id": a.id, "day": a.day, "time": a.time.strftime("%H:%M"), "site": a.site, "track": a.track.title, "volume": a.volume, "is_active": a.is_active} for a in alerts]
        return Response(data)
    except Exception as e:
        return Response({"error": str(e)}, status=500)
