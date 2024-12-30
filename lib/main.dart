
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'currency.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_screen.dart';
import 'tema.dart';
import 'package:provider/provider.dart';

 // Импорт нового экрана

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
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
