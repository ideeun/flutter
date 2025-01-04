import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  static const String baseUrl = 'https://ideeun.pythonanywhere.com/api/';
  static const String _ratesUrl = 'https://data.fx.kg/api/v1/central';
  static const String _bearerKey = 'VLWWvUeiJqa0cr7pEjQHt48gcnebzzRuLf1KrY6Jf5060c25';


  static Future<void> resetPassword(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/send-reset-email/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email}),
  );

  if (response.statusCode != 200) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to send reset password email');
  }
}



  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid username or password');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  // Функция для получения списка валют
  static Future<List<Map<String, dynamic>>> fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/currencies/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((currency) => {
          'id': currency['id'], 
          'name': currency['name'],
        }).toList();
      } else {
        throw Exception('Failed to load currencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Функция для добавления валюты
  static Future<void> addCurrency(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/currencies/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add currency: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Функция для удаления валюты
  static Future<void> deleteCurrency(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/currencies/$id/'),
      );
      if (response.statusCode == 204) {
        print('Currency deleted successfully!');
      } else {
        print('Response body: ${response.body}');  // Печать тела ответа для диагностики
        throw Exception('Failed to delete currency: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting currency: $e');
    }
  }

  

  // Функция для редактирования валюты
  static Future<void> editCurrency(int id, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/currencies/$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update currency: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Метод для очистки событий
  static Future<void> clearEvents() async {
    final response = await http.delete(Uri.parse('$baseUrl/events/'));
    if (response.statusCode != 200) {
      throw Exception('Failed to clear events: ${response.body}');
    }
  }

  // Функция для добавления события
  static Future<void> addEvent(Map<String, dynamic> event) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(event),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add event: ${response.body}');
    }
  }

  // Функция для редактирования события
  static Future<void> editEvent(Map<String, dynamic> event) async {
    final response = await http.put(
      Uri.parse('$baseUrl/events/${event['id']}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(event),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update event');
    }
  }

  // Функция для получения списка событий
  static Future<List<Map<String, dynamic>>> fetchEvents() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/events/'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body); // Декодируем данные
      return data.map((event) => event as Map<String, dynamic>).toList(); // Преобразуем каждый элемент в Map<String, dynamic>
    } else {
      throw Exception('Failed to load events');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

  // Функция для удаления события
  static Future<void> deleteEvent(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$id/'),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 204) {
        print('Event deleted successfully!');
      } else {
        throw Exception('Failed to delete event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }
  // Future<void> deleteUser(String userId) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse('$baseUrl/users/$userId/'),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //     if (response.statusCode != 204) {
  //       throw Exception('Failed to delete user');
  //     }
  //   } catch (e) {
  //     throw Exception('Error deleting user: $e');
  //   }
  // }

  static Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  static Future<void> addUser(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add user');
      }
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  static Future<void> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId/'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  static Future<void> updateUser(int userId, {String? username, String? email, String? newPassword}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/users/$userId/'),
    body: {
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (newPassword != null) 'password': newPassword,
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update user.');
  }
}

static Future<Map<String, dynamic>> checkPassword({
    required String username,
    required String oldPassword,
  }) async {
    final url = Uri.parse('$baseUrl/check-password/'); // Путь к вашему API

    // Создание тела запроса
    final body = json.encode({
      'username': username,
      'old_password': oldPassword,
    });

    // Отправка POST-запроса без токенов
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // Указываем, что тело запроса в формате JSON
      },
      body: body,
    );

    // Проверка ответа
    if (response.statusCode == 200) {
      // Если сервер ответил с успешным статусом, возвращаем данные
      return json.decode(response.body);
    } else {
      // Если произошла ошибка, выбрасываем исключение
      throw Exception('Failed to verify old password');
    }
  }


static Future<Map<String, dynamic>> getCurrencyRate() async {
  // Выполняем GET-запрос напрямую
  final response = await http.get(
    Uri.parse(_ratesUrl),
    headers: {
      'Authorization': 'Bearer $_bearerKey',
      'Content-Type': 'application/json',
    },
  );

  // Проверяем, успешен ли запрос (код 200)
  if (response.statusCode == 200) {
    // Декодируем полученные данные из JSON
    final data = json.decode(response.body);
    return data;  // Возвращаем данные
  } else {
    // В случае ошибки возвращаем пустую карту
    return {};
  }
}

static Future<bool> checkIfSuperUser(String username) async {
  final url = Uri.parse('$baseUrl/check-superuser/$username/');  // URL для проверки суперпользователя

  try {
    // Отправляем GET-запрос
    final response = await http.get(url);

    // Проверяем статус ответа
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['is_superuser'] ?? false; // Возвращаем статус суперпользователя
    } else {
      print('Failed to load superuser status. Status code: ${response.statusCode}');
      return false;
    }
  } catch (error) {
    print('Error checking superuser status: $error');
    return false;
  }
}

}