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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;


  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: isDarkMode 
            ? Color.fromARGB(255, 15, 22, 36)
            : Colors.white,
        title: Text('Edit Currency', style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(_nameController, 'Currency Name'),
          ],
        ),
        actions: <Widget>[
          _buildDialogButton('Cancel', () {
            Navigator.of(context).pop();
          }),
          _buildDialogButton('OK', () {
            final newName = _nameController.text;

            if (newName.isNotEmpty && newName != oldName) {
              _editCurrency(id, newName);
              _nameController.clear();
              Navigator.of(context).pop();
            }
          }),
        ],
      );
    },
  );
}

void _showAddDialog() {
  _nameController.clear();
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  showDialog(

    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: isDarkMode 
            ? Color.fromARGB(255, 15, 22, 36)
            : Colors.white,
        title: Text('Add Currency', style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        )),
        content: _buildTextField(_nameController, 'Currency Name'),
        actions: [
          _buildDialogButton('Cancel', () {
            Navigator.of(context).pop();
          }),
          _buildDialogButton('Add', () {
            final name = _nameController.text;
            if (name.isNotEmpty) {
              _addCurrency(name);
              Navigator.of(context).pop();
            }
          }),
        ],
      );
    },
  );
}

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyLarge,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.5)
                : Color.fromARGB(7, 97, 112, 211),
          ),
        ),
        // Цвет границы, когда поле не в фокусе
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: isDarkMode ? const Color.fromARGB(255, 168, 167, 168).withOpacity(0.5) : Colors.grey.withOpacity(0.3), // фиолетовый или серый
          ),
        ),
        // Цвет границы, когда поле в фокусе
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: isDarkMode ? const Color.fromARGB(255, 105, 114, 232) : const Color.fromARGB(255, 78, 103, 185), // фиолетовый или синий
          ),
        ),
      ),
    ),
  );
}


Widget _buildDialogButton(String label, Function() onPressed) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  return TextButton(
    onPressed: onPressed,
    child: Text(
      label,
      style: TextStyle(
        color: isDarkMode ? const Color.fromARGB(255, 88, 97, 220) : Color.fromARGB(255, 97, 123, 254), // Сиреневый для светлой темы
      ),
    ),
  );
}

  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);  // Получаем доступ к теме
  final isDarkMode = themeProvider.isDarkMode;  // Проверка на темную тему
  return MaterialApp(
    theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
  home: Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Color.fromARGB(255, 4, 13, 36), // Темный верх
                    // Color.fromARGB(255, 46, 58, 109),
                    Color.fromARGB(255, 54, 68, 103), // Темный низ
 // Темный низ
                  ]
                : [
                    Color.fromARGB(255, 65, 91, 185),
                    Color.fromARGB(255, 72, 82, 128), // Светлый верх
 // Светлый верх
                    Color.fromARGB(255, 234, 246, 255), // Светлый низ
                  ],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  title: Text(
    'Currencies',
    style: TextStyle(
      color: isDarkMode ? Colors.white : Colors.black,  // Цвет текста в зависимости от темы
    ),
  ),
  leading: IconButton(
    icon: Icon(Icons.chevron_left,
     color: isDarkMode ? Colors.white : Colors.black),
     iconSize: 30,  // Иконка кнопки назад
    onPressed: () {
      Navigator.pop(context);  // Возвращаем пользователя на предыдущий экран
    },
  ),
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
                      ? const Color.fromARGB(255, 116, 141, 245)
                      : (isDarkMode
                          ? const Color.fromARGB(255, 130, 130, 130)
                              .withOpacity(0.15)
                          : const Color.fromARGB(255, 230, 230, 230)
                              .withOpacity(0.2)),  // Изменение фона контейнера
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color.fromARGB(255, 8, 49, 255)
                                .withOpacity(0.5),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                margin: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                padding: EdgeInsets.all(16),
                child: Text(
                  currency['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Colors.black),  // Цвет текста в зависимости от темы
                    fontSize: 16,
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
                backgroundColor: const Color.fromARGB(255, 116, 137, 243),
                onPressed: () {
                  _showAddDialog();
                  
                //   _nameController.clear();
                //   showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: Text('Add Currency'),
                //         content: TextField(
                //           controller: _nameController,
                //           decoration: InputDecoration(labelText: 'Currency Name'),
                //         ),
                //         actions: [
                //           TextButton(
                //             child: Text('Cancel'),
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //             },
                //           ),
                //           TextButton(
                //             child: Text('Add'),
                //             onPressed: () {
                //               final name = _nameController.text;

                //               if (name.isNotEmpty) {
                //                 _addCurrency(name);
                //                 Navigator.of(context).pop();
                //               }
                //             },
                //           ),
                //         ],
                //       );
                //     },
                //   );
                },
                child: Icon(Icons.add),
              ),
              SizedBox(height: 10),
              if (selectedCurrency != null)
                FloatingActionButton(
                  heroTag: 'editButton',
                  backgroundColor: const Color.fromARGB(255, 151, 169, 228),
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
                  backgroundColor: const Color.fromARGB(255, 226, 94, 84),
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
    // backgroundColor: isDarkMode 
    //         ? Color.fromARGB(255, 15, 22, 36)
    //         : Colors.white,  // Цвет фона в зависимости от темы
  ),
      ),
  ),
  );
}
}