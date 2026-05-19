from django.db import models
from django.utils import timezone
from datetime import timedelta

class Track(models.Model):
    title = models.CharField(max_length=100)
    audio_file = models.FileField(upload_to='tracks/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return self.title

class Player(models.Model):
    name = models.CharField(max_length=100, unique=True)
    status = models.CharField(max_length=10, default="OFFLINE")
    last_ping = models.DateTimeField(auto_now=True)
    current_track = models.CharField(max_length=255, blank=True, null=True)
    volume = models.IntegerField(default=50)
    required_track = models.ForeignKey(
        Track, on_delete=models.SET_NULL, null=True, blank=True
    )
    def __str__(self):
        return self.name

class Schedule(models.Model):
    player = models.ForeignKey(Player, on_delete=models.CASCADE, related_name='schedules')
    day_of_week = models.IntegerField()  # 0=Lundi, 1=Mardi...
    start_time = models.TimeField()
    track = models.ForeignKey(Track, on_delete=models.SET_NULL, null=True, blank=True)
    volume = models.IntegerField(default=50)
    is_active = models.BooleanField(default=True)
    def __str__(self):
        return f"{self.player.name} - Jour {self.day_of_week} à {self.start_time}"

class ScheduledAlert(models.Model):
    DAY_CHOICES = [
        ('Lundi', 'Lundi'), ('Mardi', 'Mardi'), ('Mercredi', 'Mercredi'),
        ('Jeudi', 'Jeudi'), ('Vendredi', 'Vendredi'), ('Samedi', 'Samedi'), ('Dimanche', 'Dimanche')
    ]
    day = models.CharField(max_length=20, choices=DAY_CHOICES)
    time = models.TimeField()
    site = models.CharField(max_length=100, default="Toutes les gares")
    track = models.ForeignKey(Track, on_delete=models.CASCADE)
    volume = models.IntegerField(default=60)
    is_active = models.BooleanField(default=True)
    def __str__(self):
        return f"{self.day} à {self.time} - {self.site}"
