from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.utils import timezone
from django.utils.timezone import localtime
from datetime import timedelta
from .models import Player, Track, Playlist, PlaylistTrack, ScheduledAlert


# --- DASHBOARD ---
@api_view(['GET'])
def dashboard(request):
    try:
        players = Player.objects.select_related('required_playlist').all()
        playlists_list = Playlist.objects.all()
        tracks_list = Track.objects.all()
        threshold = timezone.now() - timedelta(seconds=15)

        player_data = []
        for p in players:
            is_online = p.last_ping and p.last_ping > threshold
            player_data.append({
                "name": p.name,
                "status": "ONLINE" if is_online else "OFFLINE",
                "current_track": p.current_track if is_online else "Déconnecté",
                "volume": p.volume,
                "last_ping": p.last_ping.isoformat() if p.last_ping else None,
                "required_playlist_id": p.required_playlist.id if p.required_playlist else None,
            })

        return Response({
            "players": player_data,
            "available_tracks": [{"id": t.id, "title": t.title} for t in tracks_list],
            "available_playlists": [{"id": pl.id, "name": pl.name} for pl in playlists_list],
        })
    except Exception as e:
        return Response({"error": str(e)}, status=500)


# --- HEARTBEAT ---
@api_view(['POST'])
def heartbeat(request):
    try:
        data = request.data
        name = data.get('name')
        client_status = data.get('current_track')

        if not name:
            return Response({"error": "Nom manquant"}, status=400)

        player, _ = Player.objects.get_or_create(name=name)
        player.last_ping = timezone.now()

        if 'volume' in data:
            player.volume = int(data.get('volume', player.volume))

        maintenant = localtime(timezone.now())
        jours_fr = {
            'Monday': 'Lundi', 'Tuesday': 'Mardi', 'Wednesday': 'Mercredi',
            'Thursday': 'Jeudi', 'Friday': 'Vendredi', 'Saturday': 'Samedi', 'Sunday': 'Dimanche'
        }
        jour_fr = jours_fr.get(maintenant.strftime('%A'), 'Lundi')
        alert_key = f"{jour_fr}_{maintenant.hour}:{maintenant.minute}"

        alerte = ScheduledAlert.objects.filter(
            is_active=True,
            day=jour_fr,
            time__hour=maintenant.hour,
            time__minute=maintenant.minute,
            site__in=[name, "Toutes les gares"]
        ).first()

        is_alert_mode = False
        track_url = ""
        track_name = ""
        playlist_name = player.required_playlist.name if player.required_playlist else "Aucune"

        if alerte and player.last_alert_key != alert_key:
            pt = PlaylistTrack.objects.filter(playlist=alerte.playlist, order=1).first()

            if pt and pt.track and pt.track.audio_file:
                is_alert_mode = True
                player.last_alert_key = alert_key
                track_url = request.build_absolute_uri(pt.track.audio_file.url)
                track_name = pt.track.title
                player.volume = alerte.volume
                player.current_track = f"ALERTE_{alert_key}"
                # Marquer l'alerte inactive après déclenchement
                alerte.is_active = False
                alerte.save()
            else:
                print(f"DEBUG: Alerte {alerte.id} échouée (fichier audio manquant)")
                is_alert_mode = False
                player.last_alert_key = alert_key

        else:
            is_alert_mode = False

            # Mise à jour du morceau actuel depuis le client
            if 'track_id' in data:
                tid = data.get('track_id')
                player.required_track = Track.objects.filter(id=tid).first()

            # Progression dans la playlist quand le client est IDLE (fin de morceau)
            if player.required_playlist and client_status == "IDLE":
                actuel = PlaylistTrack.objects.filter(
                    playlist=player.required_playlist,
                    track=player.required_track
                ).first()
                ordre = actuel.order if actuel else 0

                # Morceau suivant, ou retour au début si on est à la fin
                prochain = (
                    PlaylistTrack.objects.filter(
                        playlist=player.required_playlist,
                        order__gt=ordre
                    ).order_by('order').first()
                    or
                    PlaylistTrack.objects.filter(
                        playlist=player.required_playlist
                    ).order_by('order').first()
                )

                if prochain:
                    player.required_track = prochain.track
                    player.current_track = prochain.track.title
                    log_msg = f"Progression playlist : morceau #{prochain.order} - {prochain.track.title}"
                    print(f"[{name}] {log_msg}")

            if player.required_track and player.required_track.audio_file:
                track_name = player.required_track.title
                track_url = request.build_absolute_uri(player.required_track.audio_file.url)

        # Protection post-alerte
        if client_status == "IDLE" and player.current_track and player.current_track.startswith("ALERTE_") and not is_alert_mode:
            player.current_track = ""
            player.save()
            return Response({
                "required_track_url": "",
                "required_track_id": None,
                "is_alert": False,
                "volume": player.volume
            })

        player.save()
        return Response({
            "required_track_url": track_url,
            "required_track_name": track_name,
            # AJOUT : track_id retourné pour que le client sache quel morceau jouer
            "required_track_id": player.required_track.id if player.required_track else None,
            "required_playlist_name": playlist_name,
            "required_playlist_id": player.required_playlist.id if player.required_playlist else None,
            "volume": player.volume,
            "is_alert": is_alert_mode,
        })

    except Exception as e:
        return Response({"error": str(e)}, status=500)


# --- SET PLAYLIST ---
@api_view(['POST'])
def set_playlist(request):
    try:
        name = request.data.get('name')
        playlist_id = request.data.get('playlist_id')

        player = Player.objects.get(name=name)

        if not playlist_id:
            player.required_playlist = None
            player.required_track = None
            player.save()
            return Response({"status": "stopped"})

        pl = Playlist.objects.get(id=playlist_id)
        pt = PlaylistTrack.objects.filter(playlist=pl).order_by('order').first()
        player.required_playlist = pl
        player.required_track = pt.track if pt else None
        player.save()
        return Response({"status": "success", "playlist": pl.name})

    except Player.DoesNotExist:
        return Response({"error": "Lecteur introuvable"}, status=404)
    except Playlist.DoesNotExist:
        return Response({"error": "Playlist introuvable"}, status=404)
    except Exception as e:
        return Response({"error": str(e)}, status=500)


# --- SET VOLUME ---
@api_view(['POST'])
def set_volume(request):
    try:
        name = request.data.get('name')
        volume = request.data.get('volume')

        if volume is None:
            return Response({"error": "Volume manquant"}, status=400)

        player = Player.objects.get(name=name)
        player.volume = int(volume)
        player.save()
        return Response({"status": "success", "volume": player.volume})

    except Player.DoesNotExist:
        return Response({"error": "Lecteur introuvable"}, status=404)
    except Exception as e:
        return Response({"error": str(e)}, status=500)


# --- SYNC ALL ---
@api_view(['POST'])
def sync_all(request):
    try:
        playlist_id = request.data.get('playlist_id')
        if playlist_id:
            pl = Playlist.objects.filter(id=playlist_id).first()
            if not pl:
                return Response({"error": "Playlist introuvable"}, status=404)
            Player.objects.all().update(required_playlist=pl, required_track=None)
        else:
            Player.objects.all().update(required_playlist=None, required_track=None)
        return Response({"status": "success"})
    except Exception as e:
        return Response({"error": str(e)}, status=500)


# --- SCHEDULE ALERT ---
@api_view(['POST'])
def schedule_alert(request):
    try:
        data = request.data
        pl = Playlist.objects.filter(id=data.get('playlist_id')).first()
        if not pl:
            return Response({"error": "Playlist introuvable"}, status=404)

        ScheduledAlert.objects.create(
            day=data.get('day'),
            time=data.get('time'),
            site=data.get('site', 'Toutes les gares'),
            playlist=pl,
            volume=data.get('volume', 50),
            is_active=True,
        )
        return Response({"status": "success"})
    except Exception as e:
        return Response({"error": str(e)}, status=500)


# --- GET ALERTS ---
@api_view(['GET'])
def get_alerts(request):
    try:
        alerts = ScheduledAlert.objects.select_related('playlist').all().order_by('day', 'time')
        return Response([
            {
                "id": a.id,
                "day": a.day,
                "time": str(a.time)[:5],
                "site": a.site,
                "playlist": a.playlist.name,
                "volume": a.volume,
                "is_active": a.is_active,
            }
            for a in alerts
        ])
    except Exception as e:
        return Response({"error": str(e)}, status=500)


# --- PLAYLISTS ---
@api_view(['GET', 'POST'])
def playlists(request):
    try:
        if request.method == 'GET':
            return Response([
                {
                    "id": pl.id,
                    "name": pl.name,
                    "tracks": [
                        {"id": pt.track.id, "title": pt.track.title, "order": pt.order}
                        for pt in PlaylistTrack.objects.filter(playlist=pl).order_by('order')
                    ]
                }
                for pl in Playlist.objects.all()
            ])

        name = request.data.get('name', '').strip()
        tracks_data = request.data.get('tracks', [])

        if not name:
            return Response({"error": "Nom de playlist manquant"}, status=400)

        pl, created = Playlist.objects.get_or_create(name=name)

        if tracks_data:
            PlaylistTrack.objects.filter(playlist=pl).delete()
            for item in tracks_data:
                track = Track.objects.filter(id=item.get('track_id')).first()
                if track:
                    PlaylistTrack.objects.create(
                        playlist=pl,
                        track=track,
                        order=item.get('order', 1)
                    )

        return Response({
            "playlist_id": pl.id,
            "name": pl.name,
            "created": created,
            "tracks_saved": len(tracks_data),
        })

    except Exception as e:
        return Response({"error": str(e)}, status=500)
