from django.db import models
from django.contrib.auth.models import AbstractUser
from django.conf import settings
from django.contrib.auth.hashers import make_password


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
    is_super_user = models.BooleanField(default=False)

    def set_password(self, raw_password):
        self.password = make_password(raw_password)
        
    def save(self, *args, **kwargs):
        if not self.password.startswith(('pbkdf2_sha256$', 'bcrypt$', 'argon2')):
            self.password = make_password(self.password)
        super().save(*args, **kwargs)

    def __str__(self):
        return self.email
