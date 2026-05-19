from django.urls import path
from . import views

urlpatterns = [
    # Routes existantes
    path('heartbeat/', views.heartbeat),
    path('dashboard/', views.dashboard),
    path('sync-all/', views.sync_all_players, name='sync_all_players'),
    
    # Nouvelles routes pour le planificateur d'alertes
    path('schedule-alert/', views.schedule_alert, name='schedule_alert'),
    path('get-alerts/', views.get_scheduled_alerts, name='get_scheduled_alerts'),
]
