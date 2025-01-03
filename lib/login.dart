import 'package:flutter/material.dart';
import 'package:flutter_application_1/navigator.dart';
import 'custom_screen.dart'; // Ваш экран
import 'api_service.dart';
import 'current_user.dart'; // HTTP клиент

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isResetPassword = false;

  String? _errorMessage;
  String? _infoMessage;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (_formKey.currentState!.validate()) {
      try {
        final response = await Api.login(username, password);
        final userName = response['username'];
        print('Logged in as $userName');

        // Переход на CustomScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userName: userName),
          ),
        );
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (_emailController.text.isEmpty || !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    try {
      await Api.resetPassword(email);
      setState(() {
        _infoMessage = 'Password reset email sent! Please check your inbox.';
        _errorMessage = null;
        _emailController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _infoMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 12, 34),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 50),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (!_isResetPassword) ...[
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          foreground: Paint()..shader = LinearGradient(
                            colors: [const Color.fromARGB(255, 113, 21, 193), const Color.fromARGB(255, 66, 162, 194), const Color.fromARGB(255, 245, 43, 110)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
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
                            colors: [const Color.fromARGB(255, 113, 21, 193), const Color.fromARGB(255, 66, 162, 194), const Color.fromARGB(255, 245, 43, 110)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
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
                  ],
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  if (_infoMessage != null)
                    Text(
                      _infoMessage!,
                      style: TextStyle(color: Colors.green),
                    ),
                  SizedBox(height: 16.0),
                  if (!_isResetPassword)
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 76, 8, 235),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Login'),
                    ),
                  if (!_isResetPassword)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isResetPassword = true;
                          _errorMessage = null;
                          _infoMessage = null;
                        });
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (_isResetPassword) ...[
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          foreground: Paint()..shader = LinearGradient(
                            colors: [const Color.fromARGB(255, 113, 21, 193), const Color.fromARGB(255, 66, 162, 194), const Color.fromARGB(255, 245, 43, 110)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 141, 131, 255)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 76, 8, 235),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Send Reset Link'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
