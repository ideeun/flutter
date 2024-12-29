import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> users = [];

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();  // Новый контроллер для username

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/users/'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        if (data is List) {
          setState(() {
            users = data;
          });
        } else {
          _showSnackbar('Unexpected data format.');
        }
      } else {
        _showSnackbar('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _addUser(String username, String email, String password) async {
    try {
      if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
        _showSnackbar('Please enter a valid email address.');
        return;
      }
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/users/'), // Используем ваш эндпоинт
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (username.isEmpty || email.isEmpty || password.isEmpty) {
        _showSnackbar('All fields must be filled.');
        return;
      }

      if (response.statusCode == 201) {
        _fetchUsers(); // Обновляем список пользователей после добавления
        _showSnackbar('User added successfully!');
      } else if (response.statusCode == 400) {
        final responseBody = json.decode(response.body);
        print('Error response body: $responseBody');
        final error = responseBody['error'] ?? 'Validation error';
        _showSnackbar('Failed to add user: ${error['detail'] ?? 'Unknown error'}');
      } else {
        _showSnackbar('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _editUser(String userId) async {
    // Функция редактирования пользователя
    // Здесь можно открыть диалоговое окно и отправить PUT запрос
  }

  Future<void> _deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/users/$userId/'), // Используем ваш эндпоинт для удаления
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 204) {
        _fetchUsers(); // Обновляем список пользователей после удаления
        _showSnackbar('User deleted successfully!');
      } else {
        _showSnackbar('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showActionDialog(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose action'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                onTap: () {
                  _editUser(userId);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
                onTap: () {
                  _deleteUser(userId);
                  Navigator.of(context).pop();
                },
              ),
              
            ],
          ),
        );
      },
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New User'),
          content: Column(
            children: [
              TextField(
                controller: usernameController,  // Поле для username
                decoration: InputDecoration(hintText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(hintText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(hintText: 'Password'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _addUser(
                  usernameController.text,  // Передаем username
                  emailController.text,
                  passwordController.text,
                );
                usernameController.clear();
                emailController.clear();
                passwordController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 15, 22, 36),
      appBar: AppBar(
        title: Text('Users'),
        backgroundColor: Color.fromARGB(255, 15, 22, 36),
      ),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(user['username'] ?? 'Имя не предоставлено'),
                    onTap: () => _showActionDialog(user['id'].toString()), // Выбор действия при нажатии на пользователя
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF6C63FF),
      ),
    );
  }
}
