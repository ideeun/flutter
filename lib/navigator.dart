import 'package:flutter/material.dart';
import 'custom_screen.dart';
import 'currency_rate_screen.dart';
import 'events_screen.dart';
import 'tema.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  // final String userName;

  // HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(CustomScreen());
    _pages.add(EventsScreen());
    _pages.add(CurrencyWidget());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Stack(
        children: [
          // Навигационная панель
          CustomBottomNavigationBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            isDarkMode: isDarkMode,
          ),
          // Плавающий мячик
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: _getBallAlignment(_selectedIndex),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50), // Отступ сверху панели
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForIndex(_selectedIndex),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Alignment _getBallAlignment(int index) {
    switch (index) {
      case 0:
        return Alignment.bottomLeft;
      case 1:
        return Alignment.bottomCenter;
      case 2:
        return Alignment.bottomRight;
      default:
        return Alignment.bottomLeft;
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.event_available_outlined;
      case 2:
        return Icons.currency_exchange_rounded;
      default:
        return Icons.home;
    }
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isDarkMode;

  const CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color.fromARGB(255, 15, 22, 36)
            : const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0, selectedIndex, onItemTapped),
          _buildNavItem(Icons.event_available_outlined, 1, selectedIndex, onItemTapped),
          _buildNavItem(Icons.currency_exchange, 2, selectedIndex, onItemTapped),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, int index, int selectedIndex, Function(int) onItemTapped) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10), // Пустое пространство между мячиком и иконкой
          Icon(
            icon,
            color: selectedIndex == index ? Colors.transparent : Colors.grey,
            size: 30,
          ),
        ],
      ),
    );
  }
}
