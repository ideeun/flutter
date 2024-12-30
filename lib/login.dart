import 'package:flutter/material.dart';
import 'custom_screen.dart'; // Ваш экран
import 'api_servic.dart'; // HTTP клиент

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
      try {
        final response = await Api.login(username, password);
        final userName = response['username']; // Предполагаем, что сервер возвращает username
        print('Logged in as $userName');

        // Переход на CustomScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomScreen(userName: userName),
          ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 12, 34),  // Темный фон
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Название приложения с цветовым градиентом
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [const Color.fromARGB(255, 113, 21, 193), const Color.fromARGB(255, 66, 162, 194), const Color.fromARGB(255, 245, 43, 110)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Text(
                'FXer',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: FontStyle.italic, // Цвет текста, но фактически применяется градиент
                ),
              ),
            ),
            SizedBox(height: 50),
            
            // Форма для ввода логина и пароля
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        foreground: Paint()..shader = LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 113, 21, 193),
                            const Color.fromARGB(255, 66, 162, 194),
                            const Color.fromARGB(255, 245, 43, 110)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),  // Округление углов
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),  // Округление углов при фокусе
                        borderSide: BorderSide(color: const Color.fromARGB(255, 141, 131, 255)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        foreground: Paint()..shader = LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 113, 21, 193),
                            const Color.fromARGB(255, 66, 162, 194),
                            const Color.fromARGB(255, 245, 43, 110)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),  // Округление углов
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),  // Округление углов при фокусе
                        borderSide: BorderSide(color: const Color.fromARGB(255, 141, 131, 255)),
                      ),
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
                  // Кнопка с цветами
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 76, 8, 235), // Фиолетовый фон кнопки
                      foregroundColor: Colors.white, // Белый текст
                    ),
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
