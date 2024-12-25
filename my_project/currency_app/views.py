from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .models import Currency
from .serializers import CurrencySerializer

@api_view(['GET'])
def get_currencies(request):
    currencies = Currency.objects.all()
    serializer = CurrencySerializer(currencies, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)

@api_view(['POST'])
def add_currency(request):
    serializer = CurrencySerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
