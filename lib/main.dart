import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'package:flutter_application_1/users_screen.dart';
import 'currency.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_screen.dart';
import 'tema.dart';
import 'package:provider/provider.dart';
import 'current_user.dart'; // Импортируем UserProvider

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CurrentUser()), // Добавляем UserProvider
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: LoginScreen(),
    );
  }
}
