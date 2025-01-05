import 'package:flutter/material.dart';
import 'package:flutter_application_1/navigator.dart';
import 'api_service.dart';
import 'current_user.dart';
import 'package:provider/provider.dart';

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
        Provider.of<UserManager>(context, listen: false).setCurrentUser(userName);
        // Переход на CustomScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
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
      backgroundColor: const Color.fromARGB(255, 7, 17, 41),
      appBar: _isResetPassword
        ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left_outlined,
              color: Colors.white,
              size: 35),
            
              onPressed: () {
                setState(() {
                  _isResetPassword = false;
                  _errorMessage = null;
                  _infoMessage = null;
                });
              },
            ),
          )
        : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [const Color.fromARGB(255, 179, 81, 239), const Color.fromARGB(255, 66, 162, 194), const Color.fromARGB(255, 68, 87, 174), const Color.fromARGB(255, 245, 43, 110)],
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
                            colors: [const Color.fromARGB(255, 86, 58, 230), const Color.fromARGB(255, 77, 164, 193), const Color.fromARGB(255, 255, 5, 88)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 112, 130, 251)),
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
                            colors: [const Color.fromARGB(255, 106, 116, 255), const Color.fromARGB(255, 22, 188, 244), const Color.fromARGB(255, 245, 43, 110)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: const Color.fromARGB(255, 112, 130, 251)),
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
                        backgroundColor: const Color.fromARGB(255, 63, 83, 171),
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
                        style: TextStyle(color: const Color.fromARGB(255, 5, 95, 249)),
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
                            colors: [const Color.fromARGB(255, 86, 111, 255), const Color.fromARGB(255, 150, 98, 215), const Color.fromARGB(255, 245, 43, 110)],
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
                    SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 63, 83, 171),
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
