import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tema.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode 
            ? Color.fromARGB(255, 15, 22, 36)
            : Colors.white,
      appBar: AppBar(
        title: Text(
          'Reports',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
            backgroundColor: isDarkMode 
            ? Color.fromARGB(255, 15, 22, 36)
            : Colors.white,      ),
      body: Container(
        
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Report content will be displayed here.',
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
