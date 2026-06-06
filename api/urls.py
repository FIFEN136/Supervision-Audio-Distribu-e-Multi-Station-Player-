from django.urls import path
from . import views

urlpatterns = [
    # Route pour le script Python client (heartbeat)
    path('heartbeat/', views.heartbeat, name='heartbeat'),

    # Route pour le dashboard React (état initial)
    path('dashboard/', views.dashboard, name='dashboard'),

    # CORRECTION : route set-playlist/ était absente — le bouton playlist du dashboard ne fonctionnait pas
    path('set-playlist/', views.set_playlist, name='set_playlist'),

    # Route dédiée pour la mise à jour du volume d'un lecteur
    path('set-volume/', views.set_volume, name='set_volume'),

    # Synchronisation globale de toutes les gares
    path('sync-all/', views.sync_all, name='sync_all'),

    # Planificateur d'alertes
    path('schedule-alert/', views.schedule_alert, name='schedule_alert'),
    path('get-alerts/', views.get_alerts, name='get_alerts'),

    # Gestionnaire de playlists (GET : liste, POST : créer/mettre à jour)
    path('playlists/', views.playlists, name='playlists'),
]
