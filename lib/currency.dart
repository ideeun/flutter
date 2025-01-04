import 'package:flutter/material.dart';
import 'api_service.dart'; // Импортируем CurrencyApi
import 'tema.dart'; 
import 'package:provider/provider.dart';

class CurrencyTableScreen extends StatefulWidget {
  final Function() onCurrencyAdded;

CurrencyTableScreen({required this.onCurrencyAdded});
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

  // Используем функцию из CurrencyApi
  Future<void> _fetchCurrencies() async {
    try {
      final currenciesData = await Api.fetchCurrencies();
      setState(() {
        currencies = currenciesData;
      });
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  // Используем функцию из CurrencyApi
  Future<void> _addCurrency(String name) async {
    try {
      await Api.addCurrency(name);
      _fetchCurrencies();
      widget.onCurrencyAdded();// Обновляем список валют после добавления
      _showSnackbar('Currency added successfully!');
      // CustomScreen.initState();
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  // Используем функцию из CurrencyApi
  Future<void> _deleteCurrency(int id) async {
    try {
      await Api.deleteCurrency(id);
      _fetchCurrencies(); 
      widget.onCurrencyAdded();// Обновляем список валют после добавления
// Обновляем список валют после удаления
      _showSnackbar('Currency deleted successfully!');
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  // Используем функцию из CurrencyApi
  Future<void> _editCurrency(int id, String newName) async {
    try {
      await Api.editCurrency(id, newName);
      _fetchCurrencies();
      widget.onCurrencyAdded();// Обновляем список валют после добавления
 // Обновляем список валют после изменения
      _showSnackbar('Currency updated successfully!');
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
  final themeProvider = Provider.of<ThemeProvider>(context);  // Получаем доступ к теме
  final isDarkMode = themeProvider.isDarkMode;  // Проверка на темную тему

  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Currencies',
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,  // Цвет текста в зависимости от темы
        ),
      ),
      backgroundColor: isDarkMode
          ? Color.fromARGB(255, 6, 16, 38)
          : Colors.white,  // Цвет фона AppBar в зависимости от темы
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
                  color: isSelected
                      ? const Color.fromARGB(255, 136, 138, 246)
                      : (isDarkMode
                          ? const Color.fromARGB(255, 130, 130, 130)
                              .withOpacity(0.3)
                          : const Color.fromARGB(255, 230, 230, 230)
                              .withOpacity(0.8)),  // Изменение фона контейнера
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color.fromARGB(255, 103, 13, 237)
                                .withOpacity(0.5),
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
                    color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Colors.black),  // Цвет текста в зависимости от темы
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
                backgroundColor: const Color.fromARGB(255, 141, 118, 244),
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
                  backgroundColor: const Color.fromARGB(255, 153, 150, 236),
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
    backgroundColor: isDarkMode
        ? Color.fromARGB(255, 4, 5, 35)
        : Colors.white,  // Цвет фона в зависимости от темы
  );
}
}