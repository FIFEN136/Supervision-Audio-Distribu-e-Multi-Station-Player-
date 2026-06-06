from django.db import models

class Track(models.Model):
    title = models.CharField(max_length=100)
    audio_file = models.FileField(upload_to='tracks/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return self.title or f"Track id={self.id}"

class Playlist(models.Model):
    name = models.CharField(max_length=100, unique=True)
    tracks = models.ManyToManyField(Track, through='PlaylistTrack')
    def __str__(self):
        return self.name or f"Playlist id={self.id}"

class PlaylistTrack(models.Model):
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE, related_name='playlist_tracks')
    track = models.ForeignKey(Track, on_delete=models.CASCADE)
    order = models.PositiveIntegerField()
    class Meta:
        ordering = ['order']
        unique_together = ('playlist', 'order')
    def __str__(self):
        try:
            return f"{self.playlist.name} - {self.order}: {self.track.title}"
        except Exception:
            return f"PlaylistTrack id={self.id} (données manquantes)"

class Player(models.Model):
    name = models.CharField(max_length=100, unique=True)
    status = models.CharField(max_length=10, default="OFFLINE")
    last_ping = models.DateTimeField(null=True, blank=True)
    current_track = models.CharField(max_length=255, blank=True, null=True)
    volume = models.IntegerField(default=50)
    required_playlist = models.ForeignKey(
        Playlist, on_delete=models.SET_NULL, null=True, blank=True, related_name='players'
    )
    required_track = models.ForeignKey(
        Track, on_delete=models.SET_NULL, null=True, blank=True
    )
    last_alert_key = models.CharField(max_length=50, blank=True, null=True)
    def __str__(self):
        return self.name or f"Player id={self.id}"

class Schedule(models.Model):
    player = models.ForeignKey(Player, on_delete=models.CASCADE, related_name='schedules')
    day_of_week = models.IntegerField()
    start_time = models.TimeField()
    playlist = models.ForeignKey(Playlist, on_delete=models.SET_NULL, null=True, blank=True)
    volume = models.IntegerField(default=50)
    is_active = models.BooleanField(default=True)
    def __str__(self):
        try:
            return f"{self.player.name} - Jour {self.day_of_week} à {self.start_time}"
        except Exception:
            return f"Schedule id={self.id}"

class ScheduledAlert(models.Model):
    DAY_CHOICES = [
        ('Lundi', 'Lundi'), ('Mardi', 'Mardi'), ('Mercredi', 'Mercredi'),
        ('Jeudi', 'Jeudi'), ('Vendredi', 'Vendredi'), ('Samedi', 'Samedi'), ('Dimanche', 'Dimanche')
    ]
    day = models.CharField(max_length=20, choices=DAY_CHOICES)
    time = models.TimeField()
    site = models.CharField(max_length=100, default="Toutes les gares")
    playlist = models.ForeignKey(Playlist, on_delete=models.CASCADE)
    volume = models.IntegerField(default=60)
    is_active = models.BooleanField(default=True)
    def __str__(self):
        try:
            return f"{self.day} à {self.time} - {self.site}"
        except Exception:
            return f"ScheduledAlert id={self.id}"
