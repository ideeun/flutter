import 'package:flutter/material.dart';
import 'dart:convert'; // Для работы с JSON
import 'package:http/http.dart' as http;
import 'custom_screen.dart'; // HTTP клиент

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _errorMessage;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://127.0.0.1:8000/api/login/'); // Ваш Django API URL

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        );

        if (response.statusCode == 200) {
          // Успешный логин, переходим на CustomScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomScreen()),
          );
        } else if (response.statusCode == 401) {
          setState(() {
            _errorMessage = 'Invalid username or password';
          });
        } else if (response.statusCode == 500) {
          setState(() {
            _errorMessage = 'Server error. Please try again later.';
          });
        } else {
          setState(() {
            _errorMessage = 'Something went wrong. Please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Unable to connect to the server. Please check your connection.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
    routes: {
      '/dashboard': (context) => CustomScreen(), // Добавьте CustomScreen в маршруты
    },
  ));
}

