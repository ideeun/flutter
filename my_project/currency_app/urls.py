from django.urls import path
from .views import UserView, CurrencyView

urlpatterns = [
    path('users/', UserView.as_view(), name='user'),
    path('currencies/', CurrencyView.as_view(), name='currency'),
]


