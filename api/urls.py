from django.urls import path
from . import views

urlpatterns = [
    path('heartbeat/', views.heartbeat),
    path('dashboard/', views.dashboard),
    # On a supprimé la ligne 'config/' car elle n'existe plus dans views.py
]
