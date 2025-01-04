import 'package:flutter/material.dart';
import 'currency.dart';
import 'users_screen.dart';
import "kassa_screen.dart"; 
import "api_service.dart";
import 'login.dart';
import 'tema.dart'; 
import 'package:provider/provider.dart';
import 'dart:async';
import 'current_user.dart';

class CustomScreen extends StatefulWidget {

  // final String userName;

  // CustomScreen({required this.userName});

  @override
  _CustomScreenState createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {

    final Color textColor = Colors.white;

  // Список валют
  List<Map<String, dynamic>> currencies = [];
  String? selectedCurrencyName;
  int? selectedCurrencyId;
  late Map<String, dynamic> _currencyData;
  
 // Идентификатор выбранной валюты

  // Контроллеры для текстовых полей
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController exchangeRateController = TextEditingController();
  final TextEditingController totalController = TextEditingController();


  bool isSaleActive = false; // Состояние для продажи
  bool isBuyActive = false; 
  String currentUser = UserManager().currentUser;
// Состояние для покупки

  @override
  void initState() {
    super.initState();
    totalController.text = '0';
    fetchCurrencies();
  }

  
  
  
  Future<void> fetchCurrencies() async {
    try {
      final data = await Api.fetchCurrencies();
      if (mounted) {  // Проверка, если виджет все еще в дереве
      setState(() { 
        currencies = data;
      });
    } 
    }
    catch (e) {
    if (mounted) {
      _showErrorDialog('Failed to load currencies: $e');
    }
    }
  }

void _showClearConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Clear'),
        content: Text('Are you sure you want to clear all events? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Clear'),
            onPressed: () {
              clearEvents();  // Очищаем ивенты
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Функция для очистки всех ивентов
Future<void> clearEvents() async {
    try {
      await Api.clearEvents();
      _showSuccessDialog('All events cleared!');
    } catch (e) {
      _showErrorDialog('Failed to clear events: $e');
    }
  }



  // Функция для вычисления Total
  void calculateTotal() {
    double quantity = double.tryParse(quantityController.text) ?? 0;
    double exchangeRate = double.tryParse(exchangeRateController.text) ?? 0;
    double total = quantity * exchangeRate;
    if (mounted) {
    setState(() {
      totalController.text = total.toStringAsFixed(2); // Округляем до двух знаков после запятой
    });}
  }

  // Функция для добавления новой записи
  Future<void> addEntry() async {

    if (selectedCurrencyName == null) {
      _showErrorDialog('Please select a currency');
      return;
    }

    final event = {
      'user': currentUser,
      'currency': selectedCurrencyName,
      'quantity': double.tryParse(quantityController.text),
      'exchange_rate': double.tryParse(exchangeRateController.text),
      'total': double.tryParse(totalController.text),
      'event_type': isSaleActive ? 'SELL' : 'BUY',
    };

    try {
      await Api.addEvent(event);
      _showSuccessDialog('Event added successfully!');
      quantityController.clear();
      exchangeRateController.clear();
      totalController.text = '0';
    } catch (e) {
      _showErrorDialog('Failed to add event: $e');
    }
  }



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Функции для активации/деактивации стрелок
  void toggleSale() {
    if (mounted) {
    setState(() {
      isSaleActive = !isSaleActive;
      isBuyActive = false; // Отключаем покупку, если выбрана продажа
    });}
  }

  void toggleBuy() {
    if (mounted) {
    setState(() {
      isBuyActive = !isBuyActive;
      isSaleActive = false; // Отключаем продажу, если выбрана покупка
    });}
  }

  void logout(BuildContext context) {
  Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => LoginScreen()),
  (Route<dynamic> route) => false,
);
}


  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.isDarkMode;

  return MaterialApp(
    theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
    home: Scaffold(
      backgroundColor: isDarkMode
            ? Color.fromARGB(255, 15, 22, 36)
            : const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Color.fromARGB(255, 15, 22, 36)
            : const Color.fromARGB(255, 255, 255, 255),
        title: Text(
          'HOME',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: isDarkMode ? Colors.white : Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.brightness_3,
                color: isDarkMode ? Colors.white : Colors.black),
            onPressed: () {
              themeProvider.toggleTheme(); // Use ThemeProvider to toggle the theme
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60),
                  Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  ListTile(
                    leading: Icon(Icons.logout, color: isDarkMode ? Colors.white : Colors.black),
                    title: Text('Log Out', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      logout(context); // Log out function
                    },
                  ),
                ],
              ),
            ),
            Divider(color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.currency_exchange, color: isDarkMode ? Colors.white : Colors.black),
                    title: Text('Currencies', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CurrencyTableScreen(onCurrencyAdded: fetchCurrencies)),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black),
                    title: Text('Users', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UsersScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.document_scanner_rounded, color: isDarkMode ? Colors.white : Colors.black),
                    title: Text('Reports', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.wallet, color: isDarkMode ? Colors.white : Colors.black),
                    title: Text('Kassa', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CashScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: isDarkMode ? Colors.white : Colors.black),
                    title: Text('Clear', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    onTap: () {
                      Navigator.pop(context);
                      _showClearConfirmationDialog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          bool isPortrait = orientation == Orientation.portrait;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [
                        Color.fromARGB(255, 15, 22, 36),
                        Color.fromARGB(255, 15, 22, 31),
                        Color.fromARGB(255, 28, 39, 163),
                        Color.fromARGB(255, 61, 65, 199),
                        Color.fromARGB(255, 11, 14, 68),
                        Color.fromARGB(255, 15, 22, 36)                      ]
                    : [
                        Color.fromARGB(255, 41, 47, 120),
                        Color.fromARGB(255, 74, 77, 121),
                        Color.fromARGB(255, 188, 190, 207)
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPortrait)
                  SizedBox(height: 20),
                    // Portrait mode specific widgets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: toggleSale,
                          child: Transform.translate(
                            offset: isSaleActive ? Offset(0, -5) : Offset.zero,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSaleActive
                                      ? [const Color.fromARGB(255, 51, 5, 235), const Color.fromARGB(255, 20, 162, 233)]
                                      : [const Color.fromARGB(255, 157, 153, 153).withOpacity(0.2), const Color.fromARGB(255, 147, 145, 145).withOpacity(0.2)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isSaleActive
                                    ? [
                                        BoxShadow(
                                          color: const Color.fromARGB(255, 24, 8, 240).withOpacity(0.6),
                                          blurRadius: 10,
                                          spreadRadius: 2
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                Icons.arrow_upward,
                                color: isSaleActive ? const Color.fromARGB(255, 251, 251, 251) : textColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: toggleBuy,
                          child: Transform.translate(
                            offset: isBuyActive ? Offset(0, -5) : Offset.zero,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isBuyActive
                                      ? [const Color.fromARGB(255, 82, 14, 228), const Color.fromARGB(255, 80, 191, 224)]
                                      : [const Color.fromARGB(255, 197, 192, 205).withOpacity(0.1), Colors.white.withOpacity(0.1)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isBuyActive
                                    ? [
                                        BoxShadow(
                                          color: const Color.fromARGB(255, 24, 8, 240).withOpacity(0.6),
                                          blurRadius: 10,
                                          spreadRadius: 2
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                Icons.arrow_downward,
                                color: isBuyActive ? const Color.fromARGB(255, 238, 242, 239) : textColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  // Other form elements
                  InputDecorator(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      isDense: true,
                    ),
                    child: DropdownButton<int>(
                      value: selectedCurrencyId,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedCurrencyId = newValue;
                          selectedCurrencyName = currencies.firstWhere((currency) => currency['id'] == newValue)['name'];
                        });
                      },
                      items: currencies.map<DropdownMenuItem<int>>((currency) {
                        return DropdownMenuItem<int>(
                          value: currency['id'],
                          child: Text(
                            currency['name'],
                            style: TextStyle(
                              color: isDarkMode? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      dropdownColor: isDarkMode ? Color(0xFF0F1624) : Color.fromARGB(255, 238, 242, 239),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                      hint: Text(
                        'Select Currency',
                        style: TextStyle(
                          color: isDarkMode? textColor.withOpacity(0.6) : Color.fromARGB(0, 0, 0, 0).withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      isExpanded: true,
                      underline: Container(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                      hintText: 'Quantity',
                      hintStyle: TextStyle(color: isDarkMode? textColor.withOpacity(0.6) : Color.fromARGB(0, 0, 0, 0).withOpacity(0.6),
),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      calculateTotal();
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: exchangeRateController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      hintText: 'Exchange rate',
                      hintStyle: TextStyle(                          
                      color: isDarkMode? textColor.withOpacity(0.6) : Color.fromARGB(0, 0, 0, 0).withOpacity(0.6),
),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      calculateTotal();
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: totalController,
                    readOnly: true,
                    style: TextStyle(color :isDarkMode? textColor.withOpacity(1) : Colors.black.withOpacity(1)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      hintText: 'Total',
                      hintStyle: TextStyle(
                      color: isDarkMode? textColor.withOpacity(1) : Colors.black.withOpacity(1),
),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: addEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 106, 114, 249),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Submit'),
                    ),
                  ),  // Add space to push it down
      
               ],
              ),
            ),
          );
        },
        ),
    ),
  );
}
}