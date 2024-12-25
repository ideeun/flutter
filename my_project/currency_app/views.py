from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import Currency
from .serializers import CurrencySerializer
from currency_app.models import User  # Импорт кастомной модели

class UserView(APIView):
    """
    Класс для работы с пользователями.
    """
    def get(self, request):
        """Получение списка всех пользователей."""
        users = User.objects.all()
        data = [{'email': user.email, 'password': user.password, 'name': user.username} for user in users]
        return Response(data)

    def post(self, request):
        """Добавление нового пользователя."""
        try:
            username = request.data.get('username')
            email = request.data.get('email')
            password = request.data.get('password')

            # Логируем полученные данные
            print(f"Received data: {request.data}")

            # Проверка на отсутствие обязательных полей
            if not username or not email or not password:
                return Response({'error': 'Missing required fields'}, status=status.HTTP_400_BAD_REQUEST)

            # Проверка на существование пользователя с таким username
            if User.objects.filter(username=username).exists():
                return Response({'error': 'Username already exists'}, status=status.HTTP_400_BAD_REQUEST)

            user = User.objects.create(username=username, email=email)
            user.set_password(password)  # Хэшируем пароль
            user.save()
            
            return Response({'message': 'User created successfully'}, status=status.HTTP_201_CREATED)

        except Exception as e:
            print(f"Error occurred: {e}")
            return Response({'error': 'Internal Server Error'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class CurrencyView(APIView):
    def get(self, request):
        currencies = Currency.objects.all()
        serializer = CurrencySerializer(currencies, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = CurrencySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)