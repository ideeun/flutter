from django.db import models
from django.contrib.auth.models import AbstractUser
from django.conf import settings

class Currency(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name

class Event(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)  # Используем настройки AUTH_USER_MODEL
    currency = models.ForeignKey(Currency, on_delete=models.CASCADE)
    quantity = models.DecimalField(max_digits=10, decimal_places=2)
    exchange_rate = models.DecimalField(max_digits=10, decimal_places=4)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    event_type = models.CharField(max_length=10, choices=[('BUY', 'Buy'), ('SELL', 'Sell')])
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.currency.name} - {self.event_type} - {self.total}"

# Используйте только одну модель User, если хотите настроить свою модель, обязательно укажите это в settings.py
class User(AbstractUser):
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    name = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return self.email
