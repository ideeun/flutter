import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyTableScreen extends StatefulWidget {
  @override
  _CurrencyTableScreenState createState() => _CurrencyTableScreenState();
}

class _CurrencyTableScreenState extends State<CurrencyTableScreen> {
  List<Map<String, dynamic>> currencies = [];
  Map<String, dynamic>? selectedCurrency;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
  }

  Future<void> _fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/currencies/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          currencies = data.map((currency) => {
            'id': currency['id'],
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

  Future<void> _addCurrency(String name) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/currencies/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );
      if (response.statusCode == 201) {
        _fetchCurrencies();
        _showSnackbar('Currency added successfully!');
      } else {
        _showSnackbar('Failed to add currency: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _deleteCurrency(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/currencies/$id/'),
      );
      if (response.statusCode == 204) {
        _fetchCurrencies();
        _showSnackbar('Currency deleted successfully!');
      } else {
        _showSnackbar('Failed to delete currency: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _editCurrency(int id, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/currencies/$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': newName}),
      );
      if (response.statusCode == 200) {
        _fetchCurrencies();
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

  void _showEditDialog(int id, String oldName) {
    _nameController.text = oldName;

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
                  _editCurrency(id, newName);
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
      body: Stack(
        children: [
          ListView.builder(
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              final currency = currencies[index];
              final isSelected = selectedCurrency?['id'] == currency['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCurrency =
                        isSelected ? null : currency; // Снять выбор, если повторно нажать
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.5),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: EdgeInsets.all(16),
                  child: Text(
                    currency['name'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
          ),

          // Все кнопки в одном Positioned
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'addButton',
                  backgroundColor: Colors.green,
                  onPressed: () {
                    _nameController.clear();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Add Currency'),
                          content: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(labelText: 'Currency Name'),
                          ),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Add'),
                              onPressed: () {
                                final name = _nameController.text;

                                if (name.isNotEmpty) {
                                  _addCurrency(name);
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                if (selectedCurrency != null)
                  FloatingActionButton(
                    heroTag: 'editButton',
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      if (selectedCurrency != null) {
                        _showEditDialog(
                            selectedCurrency!['id'], selectedCurrency!['name']);
                      }
                    },
                    child: Icon(Icons.edit),
                  ),
                if (selectedCurrency != null) SizedBox(height: 10),
                if (selectedCurrency != null)
                  FloatingActionButton(
                    heroTag: 'deleteButton',
                    backgroundColor: Colors.red,
                    onPressed: () {
                      if (selectedCurrency != null) {
                        _deleteCurrency(selectedCurrency!['id']);
                        setState(() {
                          selectedCurrency = null;
                        });
                      }
                    },
                    child: Icon(Icons.delete),
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFF0F1624),
    );
  }
}
