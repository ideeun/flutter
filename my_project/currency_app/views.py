from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import CurrencySerializer, EventSerializer, UserSerializer
from currency_app.models import User  
from django.contrib.auth import authenticate
from .models import User, Currency, Event

class EventListView(APIView):
    """
    Получение списка всех событий, создание нового события и удаление всех событий
    """
    def get(self, request):
        events = Event.objects.all()
        serializer = EventSerializer(events, many=False)
        return Response(serializer.data)
    
    def post(self, request):
        # Сериализация данных, полученных в запросе
        serializer = EventSerializer(data=request.data)

        if serializer.is_valid():
            # Сохраняем новое событие в базе данных
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request):
        # Удаление всех событий
        Event.objects.all().delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    
    
class EventDetailView(APIView):
    """
    Получение, редактирование или удаление конкретного события
    """
    def get_object(self, event_id):
        try:
            return Event.objects.get(id=event_id)
        except Event.DoesNotExist:
            return None

    def get(self, request, event_id):
        event = self.get_object(event_id)
        if event is None:
            return Response({'error': 'Event not found'}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = EventSerializer(event)
        return Response(serializer.data)

    def put(self, request, event_id):
        event = self.get_object(event_id)
        if event is None:
            return Response({'error': 'Event not found'}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = EventSerializer(event, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, event_id):
        event = self.get_object(event_id)
        if event is None:
            return Response({'error': 'Event not found'}, status=status.HTTP_404_NOT_FOUND)
        
        try:
            event.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Exception as e:
            return Response({'error': f'Error deleting event: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class LoginView(APIView):
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        if not username or not password:
            return Response({'error': 'Both username and password are required'}, status=status.HTTP_400_BAD_REQUEST)

        user = authenticate(request, username=username, password=password)

        if user:
            return Response({
                'message': 'Login successful',
                'username': user.username  # Возвращаем ID пользователя
            }, status=status.HTTP_200_OK)
        return Response({'error': 'Invalid username or password'}, status=status.HTTP_401_UNAUTHORIZED)


class UserView(APIView):
    """
    Класс для работы с пользователями.
    """
    def get(self, request):
        """Получение списка всех пользователей."""
        users = User.objects.all()
        serializer = UserSerializer(users, many=True)
        return Response(serializer.data)

    def post(self, request):
        """Добавление нового пользователя."""
        serializer = UserSerializer(data=request.data)

        # Проверка данных
        if serializer.is_valid():
            serializer.save()
            return Response({'message': 'User created successfully'}, status=status.HTTP_201_CREATED)

        # Возвращаем ошибки валидации
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def put(self, request, id):
        """Редактирование пользователя."""
        try:
            user = User.objects.get(id=id)
        except User.DoesNotExist:
            return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        # Обновление данных пользователя
        serializer = UserSerializer(user, data=request.data, partial=True)

        if serializer.is_valid():
            serializer.save()
            return Response({'message': 'User updated successfully'}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, id):
        """Удаление пользователя."""
        try:
            user = User.objects.get(id=id)
        except User.DoesNotExist:
            return Response({'message': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

        # Удаление пользователя
        user.delete()
        return Response({'message': 'User deleted successfully'}, status=status.HTTP_204_NO_CONTENT)


class CurrencyView(APIView):
    
    # Получить все валюты
    def get(self, request, *args, **kwargs):
        currencies = Currency.objects.all()
        serializer = CurrencySerializer(currencies, many=True)
        return Response(serializer.data)
    
    # Добавить новую валюту
    def post(self, request, *args, **kwargs):
        serializer = CurrencySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # Получить валюту по ID
    def get_object(self, id):
        try:
            return Currency.objects.get(id=id)
        except Currency.DoesNotExist:
            return None

    # Редактировать валюту по ID
    def put(self, request, id, *args, **kwargs):
        currency = self.get_object(id)
        if not currency:
            return Response({'error': 'Currency not found'}, status=status.HTTP_404_NOT_FOUND)
        serializer = CurrencySerializer(currency, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    # Удалить валюту по ID
    def delete(self, request, id, *args, **kwargs):
        currency = self.get_object(id)
        if not currency:
            return Response({'error': 'Currency not found'}, status=status.HTTP_404_NOT_FOUND)
        
        try:
            currency.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)