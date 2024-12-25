import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyTableScreen extends StatefulWidget {
  @override
  _CurrencyTableScreenState createState() => _CurrencyTableScreenState();
}

class _CurrencyTableScreenState extends State<CurrencyTableScreen> {
  List<String> currencies = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  // Получаем валюты с сервера
  Future<void> _fetchCurrencies() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/currencies/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        currencies = data.map((currency) => currency['name'] as String).toList();
      });
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  // Добавляем валюту на сервер
  Future<void> _addCurrency(String name) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/api/currencies/add_currency/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'name': name}),
  );

  if (response.statusCode == 201) {
    _fetchCurrencies();
(); // Обновляем список после добавления валюты
  } else {
    throw Exception('Failed to add currency');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currencies'),
        backgroundColor: Color.fromARGB(255, 6, 16, 38),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                return ListTile(
                  title: Text(
                    currency,
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Показать диалоговое окно для добавления валюты
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Add Currency'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(labelText: 'Currency Name'),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            final name = _nameController.text;

                            if (name.isNotEmpty) {
                              _addCurrency(name);
                              _nameController.clear();
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Add Currency'),
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFF0F1624),
    );
  }
} 