import 'package:flutter/material.dart';
import 'dart:async'; // Для таймера перехода
import 'login.dart'; // Импортируйте ваш экран логина

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Таймер для перехода на экран логина
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 17, 41),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка приложения
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 122, 89, 192),
                    const Color.fromARGB(255, 83, 95, 173),
                    const Color.fromARGB(255, 59, 93, 143),
                    const Color.fromARGB(255, 245, 43, 110),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Icon(
                Icons.currency_exchange_outlined, // Замените на вашу иконку
                size: 120,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            // Название приложения
            // ShaderMask(
            //   shaderCallback: (bounds) {
            //     return LinearGradient(
            //       colors: [
            //         const Color.fromARGB(255, 179, 81, 239),
            //         const Color.fromARGB(255, 66, 162, 194),
            //         const Color.fromARGB(255, 68, 87, 174),
            //         const Color.fromARGB(255, 245, 43, 110),
            //       ],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ).createShader(bounds);
            //   },
            //   child: Text(
            //     'FXer',
            //     style: TextStyle(
            //       fontSize: 50,
            //       fontWeight: FontWeight.bold,
            //       fontStyle: FontStyle.italic,
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
