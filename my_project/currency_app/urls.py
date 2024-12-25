from django.urls import path
from . import views

urlpatterns = [
    path('currencies/', views.get_currencies, name='get_currencies'),
    path('currencies/add_currency/', views.add_currency, name='add_currency'),
]
