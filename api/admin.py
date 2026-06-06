from django.contrib import admin
from .models import Player, Track, Playlist, PlaylistTrack, ScheduledAlert

# Permet d'ajouter des morceaux directement à l'intérieur de la page Playlist
class PlaylistTrackInline(admin.TabularInline):
    model = PlaylistTrack
    extra = 3  # Affiche par défaut 3 lignes vides pour ajouter des morceaux rapidement

@admin.register(Playlist)
class PlaylistAdmin(admin.ModelAdmin):
    list_display = ('name', 'get_tracks_count')
    inlines = [PlaylistTrackInline]

    def get_tracks_count(self, obj):
        return obj.tracks.count()
    get_tracks_count.short_description = 'Nombre de morceaux'

@admin.register(Player)
class PlayerAdmin(admin.ModelAdmin):
    list_display = ('name', 'status', 'current_track', 'required_playlist', 'required_track', 'volume', 'last_ping')
    list_filter = ('status',)
    search_fields = ('name',)

@admin.register(ScheduledAlert)
class ScheduledAlertAdmin(admin.ModelAdmin):
    list_display = ('day', 'time', 'site', 'playlist', 'volume', 'is_active')
    list_filter = ('day', 'is_active', 'site')

# Enregistrement simple pour les pistes audio
admin.site.register(Track)
