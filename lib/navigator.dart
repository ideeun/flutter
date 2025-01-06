import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';

// Импортируйте ваши пользовательские виджеты
import 'custom_screen.dart';
import 'currency_rate_screen.dart';
import 'events_screen.dart';
import 'tema.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Настройка ThemeProvider
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color.fromARGB(255, 15, 22, 36),
            )
          : ThemeData.light(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Список страниц
  final List<Widget> _pages = [
    CustomScreen(),
    EventsScreen(),
    CurrencyWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Цвета для фона
    final backgroundColors = [
      isDarkMode
          ? const Color.fromARGB(255, 54, 68, 103) // Тёмная тема для индекса 0
          : const Color.fromARGB(255, 234, 246, 255), // Светлая тема для индекса 0
      isDarkMode ? const Color.fromARGB(255, 15, 22, 36) : Colors.white, // Индекс 1
      isDarkMode ? const Color.fromARGB(255, 15, 22, 36) : Colors.white, // Индекс 2
    ];

    // Проверка длины массивов
    assert(_pages.length == backgroundColors.length,
        'Количество страниц (_pages) и цветов (backgroundColors) должно совпадать.');

    return Scaffold(
      backgroundColor: backgroundColors[_selectedIndex],
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 70,
        backgroundColor: backgroundColors[_selectedIndex],
        color: isDarkMode
            ? const Color.fromARGB(255, 7, 23, 59)
            : const Color.fromARGB(255, 112, 129, 170),
        buttonBackgroundColor: const Color.fromARGB(255, 123, 137, 227),
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.event_available_outlined, size: 30, color: Colors.white),
          Icon(Icons.currency_exchange_rounded, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          debugPrint('Selected index: $index'); // Отладочный вывод
          setState(() {
            // Убедитесь, что индекс корректен
            _selectedIndex = index.clamp(0, _pages.length - 1);
          });
        },
      ),
    );
  }
}
