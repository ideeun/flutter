from rest_framework import serializers
from .models import Currency
from django.contrib.auth.models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'full_name', 'password']  # Добавьте поля, которые вы хотите отправлять
        extra_kwargs = {'password': {'write_only': True}}  # Пароль должен быть только для записи

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user


class CurrencySerializer(serializers.ModelSerializer):
    class Meta:
        model = Currency
        fields = ['id', 'name']
