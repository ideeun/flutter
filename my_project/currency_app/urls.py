from django.urls import path
from .views import UserView, CurrencyView, LoginView, EventListView,EventDetailView,  CheckSuperuserView, CheckPasswordView,PasswordResetRequest, PasswordResetConfirm


urlpatterns = [
    path('users/', UserView.as_view(), name='user'),
    path('currencies/', CurrencyView.as_view(), name='currency'),
    path('currencies/<int:id>/', CurrencyView.as_view(), name='currency-detail'),
    path('login/', LoginView.as_view(), name='login'),
    path('events/', EventListView.as_view(), name='event-create'),
    path('events/<int:event_id>/', EventDetailView.as_view(), name='event-detail'),
    path('users/<int:id>/', UserView.as_view(), name='user_detail'), 
    path('check-superuser/<str:username>/', CheckSuperuserView.as_view(), name='check_superuser'),
    path('check-password/', CheckPasswordView.as_view(), name='check-password'),
    path('reset-password/<str:uidb64>/<str:token>/', PasswordResetConfirm.as_view(), name='reset-password'),
    path('password-reset/', PasswordResetRequest.as_view(), name='password-reset'),

] # Редактирование и удаление пользователя





