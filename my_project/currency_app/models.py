from django.db import models
from django.contrib.auth.models import AbstractUser
from django.conf import settings

class Currency(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name

class Event(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    user = models.CharField(max_length=100)    
    currency = models.CharField(max_length=50)
    quantity = models.DecimalField(max_digits=10, decimal_places=2)
    exchange_rate = models.DecimalField(max_digits=10, decimal_places=4)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    event_type = models.CharField(max_length=10, choices=[('BUY', 'Buy'), ('SELL', 'Sell')])
    

    def __str__(self):
        return f"Event {self.id}"  # Здесь предполагается, что у пользователя есть поле 'username'

# Используйте только одну модель User, если хотите настроить свою модель, обязательно укажите это в settings.py
class User(AbstractUser):
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=255)
    name = models.CharField(max_length=255, blank=True, null=True)

    def __str__(self):
        return self.email
