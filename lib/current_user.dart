import 'package:flutter/material.dart';

class CurrentUser with ChangeNotifier {
  String? _username;

  String? get username => _username;

  // Устанавливаем текущего пользователя
  void setUser(String username) {
    _username = username;
    notifyListeners(); // Уведомляем всех слушателей об изменении
  }

  // Убираем текущего пользователя (выход)
  void logout() {
    _username = null;
    notifyListeners();
  }
}
