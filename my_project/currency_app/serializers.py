from .models import Currency
from django.contrib.auth.models import User
from rest_framework import serializers, status
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Event
from currency_app.models import Currency
from .models import User

class CurrencySerializer(serializers.ModelSerializer):
    class Meta:
        model = Currency
        fields = ['id', 'name']
# Создание сериализатора для модели Event
class EventSerializer(serializers.ModelSerializer):
    class Meta:
        model = Event
        fields = ['id','user','currency', 'quantity', 'exchange_rate', 'total', 'event_type', 'created_at']

# API для создания события

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id','username', 'email','password']  # Поля для работы
        extra_kwargs = {'password': {'write_only':False }}  # Пароль только для записи

    def create(self, validated_data):
        try:# Хэшируем пароль перед сохранением
            user = User(
                email=validated_data['email'],
                username=validated_data['username']
            )
            user.set_password(validated_data['password'])
            user.save()
            return user
        except Exception as e:
            raise serializers.ValidationError(f"Ошибка создания пользователя: {str(e)}")


