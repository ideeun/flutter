import 'package:flutter/material.dart';

class UserManager with ChangeNotifier {
  static final UserManager _instance = UserManager._internal();
  String _currentUser = '';

  // Приватный конструктор для синглтона
  UserManager._internal();

  // Фабричный метод для доступа к экземпляру
  factory UserManager() {
    return _instance;
  }

  // Устанавливаем текущего пользователя
  void setCurrentUser(String user) {
    _currentUser = user;
    notifyListeners(); // Уведомляем слушателей об изменении
  }

  // Получаем текущего пользователя
  String get currentUser => _currentUser;
}
