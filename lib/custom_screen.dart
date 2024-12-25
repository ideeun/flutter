import 'package:flutter/material.dart';
import 'currency.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'users_screen.dart';

class CustomScreen extends StatefulWidget {
  @override
  _CustomScreenState createState() => _CustomScreenState();
}

class _CustomScreenState extends State<CustomScreen> {
  final Color textColor = Colors.white;

  // Список валют
  List<String> currencies = [];
  String? selectedCurrency;  // Начальная валюта

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
    _fetchCurrencies(); // Начальное значение Total
  }

  Future<void> _fetchCurrencies() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/currencies/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print(data);
      setState(() {
        currencies = data.map((currency) => currency['name'] as String).toList();
      });
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  // Future<void> _fetchCurrencies() async {
  //   final url = Uri.parse('http://127.0.0.1:8000/api/currencies/'); // URL вашего API

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       // Если запрос успешен, парсим данные
  //       List<String> fetchedCurrencies = List<String>.from(json.decode(response.body));
  //       setState(() {
  //         currencies = fetchedCurrencies;
  //         selectedCurrency = currencies.isNotEmpty ? currencies.first : null; // Обновляем выбранную валюту
  //       });
  //     } else {
  //       // Если ошибка в запросе
  //       throw Exception('Failed to load currencies');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

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
  void addEntry() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Entry Added'),
          content: Text('Currency: $selectedCurrency\nQuantity: ${quantityController.text}\nExchange Rate: ${exchangeRateController.text}\nTotal: ${totalController.text}'),
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

    // Очистка полей после добавления
    quantityController.clear();
    exchangeRateController.clear();
    totalController.text = '0';
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
                Scaffold.of(context).openDrawer();  // Открытие Drawer при нажатии на иконку гамбургера
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
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.currency_exchange, color: textColor),
              title: Text('Currencies', style: TextStyle(color: textColor)),
              onTap: () {
                // Действие для "Home" (например, вернуться на главный экран)
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
                // Переход на экран "Users"
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UsersScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.wallet, color: textColor),
              title: Text('Kassa', style: TextStyle(color: textColor)),
              onTap: () {
                // Действие для "Log Out"
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.document_scanner, color: textColor),
              title: Text('Report', style: TextStyle(color: textColor)),
              onTap: () {
                // Действие для "Log Out"
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: textColor),
              title: Text('Clear', style: TextStyle(color: textColor)),
              onTap: () {
                // Действие для "Log Out"
                Navigator.pop(context);
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
              // SizedBox(height: 50),
              // Row(
              //   children: [
              //     Icon(Icons.menu, color: textColor),
              //     Expanded(
              //       child: Center(
              //         child: Text(
              //           'HOME',
              //           style: TextStyle(
              //             fontSize: 32,
              //             fontWeight: FontWeight.bold,
              //             color: textColor,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 40),
              // SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: toggleSale,  // Нажатие для активации продажи
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        color: isSaleActive ? Colors.blueAccent : textColor, // Меняем цвет при активации
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: toggleBuy,  // Нажатие для активации покупки
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_downward,
                        color: isBuyActive ? Colors.green : textColor, // Меняем цвет при активации
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Комбо-бокс для валюты
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: selectedCurrency,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCurrency = newValue;
                    });
                  },
                  items: currencies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Color(0xFF0F1624),  // Тема выпадающего списка
                  style: TextStyle(color: textColor),
                  hint: Text(
                    'Select Currency',
                    style: TextStyle(color: textColor.withOpacity(0.6)),
                  ),
                  isExpanded: true, // чтобы раскрывающийся список занимал всю ширину
                  underline: Container(), // скрывает стандартную линию под DropdownButton
                ),
              ),
              SizedBox(height: 20),
              // Поле для количества
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
                  calculateTotal(); // Пересчитываем Total при изменении количества
                },
              ),
              SizedBox(height: 20),
              // Поле для курса обмена
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
                  calculateTotal(); // Пересчитываем Total при изменении курса
                },
              ),
              SizedBox(height: 20),
              // Поле для итоговой суммы (Total)
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
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: addEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('ADD', style: TextStyle(color: textColor)),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('EVENTS', style: TextStyle(color: textColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
