from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from django.core.mail import send_mail
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.conf import settings
from hashlib import sha256
from django.utils import timezone
from django.shortcuts import render
from rest_framework.permissions import AllowAny
from django.utils.encoding import force_str  
from .serializers import UserSerializer , CurrencySerializer,EventSerializer
from .models import User, Currency, Event
from django.contrib.auth import authenticate
from currency_app.models import User  
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.hashers import check_password


class CheckPasswordView(APIView):
    """
    Проверка старого пароля пользователя
    """
    def post(self, request):
        username = request.data.get('username')
        old_password = request.data.get('old_password')

        try:
            # Получаем пользователя
            user = User.objects.get(username=username)

            # Проверяем старый пароль
            if check_password(old_password, user.password):
                return Response({'message': 'Пароль верен'}, status=status.HTTP_200_OK)
            else:
                return Response({'error': 'Неверный пароль'}, status=status.HTTP_400_BAD_REQUEST)
        except User.DoesNotExist:
            return Response({'error': 'Пользователь не найден'}, status=status.HTTP_404_NOT_FOUND)


class CheckSuperuserView(APIView):
    def get(self, request, username, *args, **kwargs):
        try:
            user = User.objects.get(username=username)  # Ищем пользователя по имени
            if user.is_superuser:
                return Response({'is_superuser': True}, status=200)
            else:
                return Response({'is_superuser': False}, status=200)
        except User.DoesNotExist:
            return Response({'detail': 'User not found'}, status=404)
        

class PasswordResetRequest(APIView):
    """
    Запрос на сброс пароля.
    """
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        try:
            user = User.objects.get(email=email)
            # Генерация токена
            token = self.generate_token(user)
            uid = urlsafe_base64_encode(bytes(str(user.pk), 'utf-8'))  # используем bytes()
            reset_url = f"{request.scheme}://{request.get_host()}/api/v1/reset-password/{uid}/{token}"

            # Отправка письма с инструкциями
            send_mail(
                'Запрос на сброс пароля',
                f'<h1>Сброс пароля</h1><br>Для сброса пароля перейдите по ссылке: {reset_url}',
                settings.DEFAULT_FROM_EMAIL,
                [email],
                fail_silently=True,
                html_message=f'<html><body style="text-align: center; background: linear-gradient(158deg, rgba(2,0,36,1) 0%, rgba(9,9,121,1) 60%, rgba(0,226,255,1) 100%); padding: 100px 0;"><h1 style="color:#3EA1F2; font-size: 32px">Сброс пароля.</h1><h3 style="color: white; font-size: 20px">Был запрошен сброс пароля для пользователя {user.username},<br><span style="color: #FF4545">если это были не вы, не реагируйте на это письмо.</span><br>Для сброса пароля нажмите кнопку ниже.</h3><a href="{reset_url}" style="color: #ffffff; text-decoration: none;"><button style="padding: 15px 50px; color: #ffffff; background: linear-gradient(90deg, #42A4F5, #2088E5); border-radius:10px; border: none">Cброс пароля</button></a></body></html>'
            )

            return Response({"message": "Password reset link sent"}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

    def generate_token(self, user):
        # Генерация токена для сброса пароля с использованием SHA256
        timestamp = int(timezone.now().timestamp())
        timestamp_hours = timestamp - (timestamp % 3600)  # Округляем до ближайшего часа
        token_string = f"{user.email}-{user.id}-{user.password}-{timestamp_hours}"
        return sha256(token_string.encode()).hexdigest()[:32]


class PasswordResetConfirm(APIView):
    """
    Подтверждение сброса пароля.
    """
    permission_classes = [AllowAny]
    template_name = 'password_reset_confirm.html'

    def get(self, request, uidb64, token):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))  # заменили force_bytes на force_str
            user = User.objects.get(pk=uid)
            # Проверка токена
            if self.check_token(user, token):
                return render(request, self.template_name, {
                    'validlink': True,
                    'uidb64': uidb64,
                    'token': token
                })
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            pass
        return render(request, self.template_name, {'validlink': False})

    def post(self, request, uidb64, token, *args, **kwargs):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))  # заменили force_bytes на force_str
            user = User.objects.get(pk=uid)
            if self.check_token(user, token):
                password1 = request.POST.get('new_password1')
                password2 = request.POST.get('new_password2')

                # Проверка пароля
                if not password1 or not password2:
                    return render(request, self.template_name, {
                        'validlink': True,
                        'error': 'Please enter both passwords',
                        'token': token,
                        'uidb64': uidb64
                    })

                if password1 != password2:
                    return render(request, self.template_name, {
                        'validlink': True,
                        'error': 'Passwords do not match',
                        'token': token,
                        'uidb64': uidb64
                    })

                if len(password1) < 8:
                    return render(request, self.template_name, {
                        'validlink': True,
                        'error': 'Пароль должен содержать не менее 4 символов',
                        'token': token,
                        'uidb64': uidb64
                    })

                user.set_password(password1)
                user.save()
                return render(request, self.template_name, {
                    'validlink': True,
                    'success': True
                })

        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            pass

        return render(request, self.template_name, {'validlink': False})

    def check_token(self, user, token):
        # Проверка токена
        current_time = int(timezone.now().timestamp())
        for hours in range(24):
            check_time = current_time - (current_time % 3600) - (hours * 3600)
            token_string = f"{user.email}-{user.id}-{user.password}-{check_time}"
            expected_token = sha256(token_string.encode()).hexdigest()[:32]
            if token == expected_token:
                return True
        return False


class EventListView(APIView):
    """
    
    Получение списка всех событий, создание нового события и удаление всех событий
    """
    def get(self, request):
        events = Event.objects.all()
        serializer = EventSerializer(events, many=True)  # Добавлено `many=True`
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
        

