import 'package:flutter/material.dart';
import 'package:flutter_application_1/splash_screen.dart';
import 'tema.dart';
import 'package:provider/provider.dart';
import 'current_user.dart'; 

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserManager()),
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
      home: SplashScreen(),
    );
  }
}
