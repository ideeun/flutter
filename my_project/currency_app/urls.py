from django.urls import path
from .views import UserView, CurrencyView, LoginView, EventListView,EventDetailView,PasswordResetRequest, PasswordResetConfirm


urlpatterns = [
    path('users/', UserView.as_view(), name='user'),
    path('currencies/', CurrencyView.as_view(), name='currency'),
    path('currencies/<int:id>/', CurrencyView.as_view(), name='currency-detail'),
    path('login/', LoginView.as_view(), name='login'),
    path('events/', EventListView.as_view(), name='event-create'),
    path('events/<int:event_id>/', EventDetailView.as_view(), name='event-detail'),
    path('users/<int:id>/', UserView.as_view(), name='user_detail'), 
    path('send-reset-email/', PasswordResetRequest.as_view(), name='send_reset_email'),
    path('reset-password/<uidb64>/<token>/', PasswordResetConfirm.as_view(), name='reset_password_confirm'),
] # Редактирование и удаление пользователя





