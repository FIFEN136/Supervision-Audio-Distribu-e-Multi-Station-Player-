from django.contrib import admin
from .models import Player, Track, ScheduledAlert

# Enregistrement des modèles d'origine
admin.site.register(Player)
admin.site.register(Track)

# Enregistrement du nouveau modèle pour le planificateur d'alertes
admin.site.register(ScheduledAlert)
