import 'package:flutter/material.dart';
import 'currency.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'users_screen.dart';
import 'events_screen.dart'; // Новый экран для отображения ивентов

class CustomScreen extends StatefulWidget {
  final int userId;

CustomScreen({required this.userId});

  @override
  _CustomScreenState createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  final Color textColor = Colors.white;

  // Список валют
  List<Map<String, dynamic>> currencies = [];
  String? selectedCurrencyName;
  int? selectedCurrencyId; // Идентификатор выбранной валюты

  // Контроллеры для текстовых полей
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController exchangeRateController = TextEditingController();
  final TextEditingController totalController = TextEditingController();

  bool isSaleActive = false; // Состояние для продажи
  bool isBuyActive = false; // Состояние для покупки

  @override
  void initState() {
    super.initState();
    totalController.text = '0';
    _fetchCurrencies(); // Загрузка валют
  }

  Future<void> _fetchCurrencies() async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/currencies/'));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    setState(() {
      currencies = data.map((currency) {
        return {
          'id': currency['id'], // Поле 'id' предполагается в ответе сервера
          'name': currency['name'], // Поле 'name' для названия валюты
        };
      }).toList();
    });
  } else {
    throw Exception('Failed to load currencies');
  }
}


  // Функция для вычисления Total
  void calculateTotal() {
    double quantity = double.tryParse(quantityController.text) ?? 0;
    double exchangeRate = double.tryParse(exchangeRateController.text) ?? 0;
    double total = quantity * exchangeRate;

    setState(() {
      totalController.text = total.toStringAsFixed(2); // Округляем до двух знаков после запятой
    });
  }

  // Функция для добавления новой записи
  Future<void> addEntry() async {
  if (selectedCurrencyName == null) {  // Проверяем, что название валюты выбрано
    _showErrorDialog('Please select a currency');
    return;
  }

  final user = widget.userId.toString();
  final quantity = double.tryParse(quantityController.text);
  final exchangeRate = double.tryParse(exchangeRateController.text);
  final total = double.tryParse(totalController.text);

  if (quantity == null || exchangeRate == null || total == null) {
    _showErrorDialog('Please enter valid numbers for quantity, exchange rate, and total.');
    return;
  }

  if (!isSaleActive && !isBuyActive) {
    _showErrorDialog('Please select whether it is a sale or a purchase.');
    return;
  }

  final url = 'http://127.0.0.1:8000/api/events/';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'user': int.parse(user),
      'currency': selectedCurrencyName,  // Передаем название валюты
      'quantity': quantity,
      'exchange_rate': exchangeRate,
      'total': total,
      'event_type': isSaleActive ? 'SELL' : isBuyActive ? 'BUY' : 'UNKNOWN',
    }),
  );

  if (response.statusCode == 201) {
    _showSuccessDialog('Event added successfully!');
    quantityController.clear();
    exchangeRateController.clear();
    totalController.text = '0';
  } else {
    _showErrorDialog('Failed to add event. Error: ${response.body}');
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
    setState(() {
      isSaleActive = !isSaleActive;
      isBuyActive = false; // Отключаем покупку, если выбрана продажа
    });
  }

  void toggleBuy() {
    setState(() {
      isBuyActive = !isBuyActive;
      isSaleActive = false; // Отключаем продажу, если выбрана покупка
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 6, 16, 38),
        title: Text('HOME', style: TextStyle(color: textColor)),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF0F1624),
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Text(
                'Menu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            ListTile(
              leading: Icon(Icons.currency_exchange, color: textColor),
              title: Text('Currencies', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CurrencyTableScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: textColor),
              title: Text('Users', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.event, color: textColor),
              title: Text('Events', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventsScreen()), // Новый экран для ивентов
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1624), Color(0xFF6C63FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: toggleSale,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        color: isSaleActive ? Colors.blueAccent : textColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: toggleBuy,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_downward,
                        color: isBuyActive ? Colors.green : textColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DropdownButton<int>(
    value: selectedCurrencyId,
    onChanged: (int? newValue) {
    setState(() {
      selectedCurrencyId = newValue;
      selectedCurrencyName = currencies.firstWhere((currency) => currency['id'] == newValue)['name']; // Сохраняем название валюты
    });
  },
  items: currencies.map<DropdownMenuItem<int>>((currency) {
    return DropdownMenuItem<int>(
      value: currency['id'],
      child: Text(
        currency['name'],
        style: TextStyle(color: textColor),
      ),
    );
  }).toList(),
  dropdownColor: Color(0xFF0F1624),
  style: TextStyle(color: textColor),
  hint: Text(
    'Select Currency',
    style: TextStyle(color: textColor.withOpacity(0.6)),
  ),
  isExpanded: true,
  underline: Container(),
),

              SizedBox(height: 20),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  hintText: 'Quantity',
                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
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
                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
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
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  hintText: 'Total',
                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
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
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
