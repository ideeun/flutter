import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyTableScreen extends StatefulWidget {
  @override
  _CurrencyTableScreenState createState() => _CurrencyTableScreenState();
}

class _CurrencyTableScreenState extends State<CurrencyTableScreen> {
  List<Map<String, dynamic>> currencies = []; // Сохраняем валюты с их id
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  // Получаем валюты с сервера
  Future<void> _fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/currencies/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          currencies = data.map((currency) => {
            'id': currency['id'], // Добавляем id
            'name': currency['name'],
          }).toList();
        });
      } else {
        _showSnackbar('Failed to load currencies: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  // Добавляем валюту на сервер
  Future<void> _addCurrency(String name) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/currencies/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        _fetchCurrencies(); // Обновляем список валют после добавления
        _showSnackbar('Currency added successfully!');
      } else {
        _showSnackbar('Failed to add currency: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  // Удаляем валюту с сервера
  Future<void> _deleteCurrency(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/currencies/$id/'),
      );

      if (response.statusCode == 204) {
        _fetchCurrencies(); // Обновляем список валют после удаления
        _showSnackbar('Currency deleted successfully!');
      } else {
        _showSnackbar('Failed to delete currency: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  // Редактируем валюту на сервере
  Future<void> _editCurrency(int id, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/currencies/$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': newName,
        }),
      );

      if (response.statusCode == 200) {
        _fetchCurrencies(); // Обновляем список валют после редактирования
        _showSnackbar('Currency updated successfully!');
      } else {
        _showSnackbar('Failed to update currency: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Показать диалоговое окно для редактирования валюты
  void _showEditDialog(int id, String oldName) {
    _nameController.text = oldName; // Заполняем контроллер текущим значением валюты

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Currency'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Currency Name'),
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
                final newName = _nameController.text;

                if (newName.isNotEmpty && newName != oldName) {
                  _editCurrency(id, newName); // Передаем id валюты для редактирования
                  _nameController.clear();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
                    currency['name'],
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          _showEditDialog(currency['id'], currency['name']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.white),
                        onPressed: () {
                          _deleteCurrency(currency['id']);
                        },
                      ),
                    ],
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
