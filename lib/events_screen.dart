import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'api_servic.dart';
import 'tema.dart'; 
import 'package:provider/provider.dart';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> filteredEvents = [];
  Map<String, dynamic>? selectedEvent;

  List<Map<String, dynamic>> currencies = [];
  String? selectedCurrency;
  String eventTypeFilter = 'All';

  Future<void> _fetchEvents() async {
    try {
      final eventList = await Api.fetchEvents();
      setState(() {
        events = eventList;
        filteredEvents = eventList;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> _deleteEvent(int eventId) async {
  try {
    await Api.deleteEvent(eventId);  // Просто вызываем функцию
    setState(() {
      events.removeWhere((event) => event['id'] == eventId);
      selectedEvent = null;
      filterEvents();
    });
  } catch (e) {
    print('Error deleting event: $e');
  }
}


  Future<void> _editEvent(Map<String, dynamic> updatedEvent) async {
  try {
    // Сохраняем старое значение даты (created_at), чтобы не менять её при редактировании
    updatedEvent['created_at'] = selectedEvent!['created_at'];

    // Отправляем обновленные данные (без изменений в created_at)
    await Api.editEvent(updatedEvent);

    setState(() {
      // Находим индекс события, которое нужно обновить
      int index = events.indexWhere((event) => event['id'] == updatedEvent['id']);
      if (index != -1) {
        // Обновляем событие в списке
        events[index] = updatedEvent;
      }
      selectedEvent = updatedEvent;
      filterEvents();
    });
  } catch (e) {
    print('Error editing event: $e');
  }
}


  Future<void> _fetchCurrencies() async {
    try {
      final currencyList = await Api.fetchCurrencies();
      setState(() {
        currencies = currencyList;
      });
    } catch (e) {
      print('Error fetching currencies: $e');
    }
  }
  void filterEvents() {
    setState(() {
      filteredEvents = events.where((event) {
        bool matchesCurrency = selectedCurrency == null || selectedCurrency == 'All' || event['currency'] == selectedCurrency;
        bool matchesType = eventTypeFilter == 'All' || event['event_type'] == eventTypeFilter;
        return matchesCurrency && matchesType;
      }).toList();
    });
  }


  void sortByCurrency() {
    setState(() {
      events.sort((a, b) => a['currency'].compareTo(b['currency']));
      filterEvents();
    });
  }

  void sortByEventType() {
    setState(() {
      events.sort((a, b) => a['event_type'].compareTo(b['event_type']));
      filterEvents();
    });
  }
  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _fetchCurrencies();
  }
  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.isDarkMode;  // Проверка на темную тему

  return Scaffold(
    backgroundColor: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : Colors.white, // Фон для Scaffold
    appBar: AppBar(
      backgroundColor: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : const Color.fromARGB(255, 255, 255, 255),  // Фон AppBar
      title: Text(
        'Events Table',
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),  // Цвет текста в AppBar
      ),
      iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),  // Цвет иконок в AppBar
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // Фильтры
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Фильтр по валюте
              DropdownButton<String>(
                value: selectedCurrency ?? 'All', // Provide a default value like 'All' if null
                hint: Text('Select Currency', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                onChanged: (newValue) {
                  setState(() {
                    selectedCurrency = newValue;
                    filterEvents();
                  });
                },
                items: ['All', ...currencies.map((currency) {
                  return currency['name'];
                })].map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                  );
                }).toList(),
              ),
              SizedBox(width: 20),
              // Фильтр по типу события
              DropdownButton<String>(
                value: eventTypeFilter,
                onChanged: (newValue) {
                  setState(() {
                    eventTypeFilter = newValue!;
                    filterEvents();
                  });
                },
                items: ['All', 'SELL', 'BUY'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                  );
                }).toList(),
              ),
            ],
          ),
          // Таблица событий
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              showCheckboxColumn: false,
              columns: [
                DataColumn(label: Text('Date', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                DataColumn(label: Text('User', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                DataColumn(label: Text('Currency', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                DataColumn(label: Text('Quantity', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                DataColumn(label: Text('Exchange Rate', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                DataColumn(label: Text('Total', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                DataColumn(label: Text('Event Type', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
              ],
              rows: filteredEvents.map((event) {
                bool isSelected = selectedEvent != null && selectedEvent!['id'] == event['id'];
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        event['created_at'] != null && event['created_at'].isNotEmpty
                            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(event['created_at']))
                            : 'Invalid Date',
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),                     
                    DataCell(Text(event['user'].toString(), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                    DataCell(Text(event['currency'].toString(), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                    DataCell(Text(event['quantity'].toString(), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                    DataCell(Text(event['exchange_rate'].toString(), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                    DataCell(Text(event['total'].toString(), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                    DataCell(Text(event['event_type'], style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                  ],
                  selected: isSelected,
                  onSelectChanged: (selected) {
                    setState(() {
                      selectedEvent = isSelected ? null : event;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Кнопка редактирования
        if (selectedEvent != null)
          FloatingActionButton(
            heroTag: 'editButton',
            onPressed: selectedEvent == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEventScreen(
                          event: selectedEvent!,
                          onSave: (updatedEvent) {
                            _editEvent(updatedEvent);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
            child: Icon(Icons.edit),
            tooltip: 'Edit Event',
            backgroundColor: Colors.blue,
          ),
        SizedBox(height: 10),
        // Кнопка удаления
        if (selectedEvent != null)
          FloatingActionButton(
            heroTag: 'deleteButton',
            onPressed: selectedEvent == null
                ? null
                : () {
                    _deleteEvent(selectedEvent!['id']);
                  },
            child: Icon(Icons.delete),
            tooltip: 'Delete Event',
            backgroundColor: Colors.red,
          ),
      ],
    ),
  );
}

}






// Страница редактирования события
class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final Function(Map<String, dynamic>) onSave;

  EditEventScreen({required this.event, required this.onSave});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController quantityController;
  late TextEditingController exchangeRateController;
  late TextEditingController totalController;
  late TextEditingController eventTypeController;
  late TextEditingController userController;

  List<Map<String, dynamic>> currencies = [];
  String? selectedCurrency;
  late String eventType;

  Future<void> _fetchCurrencies() async {
    try {
      final currencyList = await Api.fetchCurrencies();
      setState(() {
        currencies = currencyList;
      });
    } catch (e) {
      print('Error fetching currencies: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.event['quantity'].toString());
    exchangeRateController = TextEditingController(text: widget.event['exchange_rate'].toString());
    totalController = TextEditingController(text: widget.event['total'].toString());
    userController = TextEditingController(text: widget.event['user'] ?? '');
    selectedCurrency = widget.event['currency'] ?? 'default_currency';
    eventType = widget.event['event_type'] ?? 'SELL';
    _fetchCurrencies();
  }

  void _updateTotal() {
    double quantity = double.tryParse(quantityController.text) ?? 0;
    double exchangeRate = double.tryParse(exchangeRateController.text) ?? 0;
    double total = quantity * exchangeRate;
    totalController.text = total.toStringAsFixed(2);
  }

  void toggleEventType(String type) {
    setState(() {
      eventType = type;
    });
  }

  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.isDarkMode;  // Проверка на темную тему

  return Scaffold(
    backgroundColor: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : Colors.white, // Фон для Scaffold
    appBar: AppBar(
      title: Text(
        'Edit Event',
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),  // Цвет текста в AppBar
      ),
      backgroundColor: isDarkMode ? Color.fromARGB(255, 15, 22, 36) : const Color.fromARGB(255, 255, 255, 255), // Фон AppBar
      iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),  // Цвет иконок в AppBar
    ),
    body: Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Строка с кнопками для переключения типа события
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => toggleEventType('SELL'),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: eventType == 'SELL'
                            ? const Color.fromARGB(255, 173, 125, 241)
                            : const Color.fromARGB(255, 132, 130, 130).withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      color: eventType == 'SELL' ? const Color.fromARGB(255, 173, 125, 241) : const Color.fromARGB(255, 170, 169, 169),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () => toggleEventType('BUY'),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: eventType == 'BUY'
                            ? const Color.fromARGB(255, 173, 125, 241)
                            : const Color.fromARGB(255, 142, 141, 141).withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_downward,
                      color: eventType == 'BUY' ? const Color.fromARGB(255, 173, 125, 241) : const Color.fromARGB(255, 175, 173, 173),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Поле для выбора валюты
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: isDarkMode ? Colors.white : Colors.black, width: 1), // Цвет рамки
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: DropdownButton<String>(
                value: selectedCurrency,
                onChanged: (newValue) {
                  setState(() {
                    selectedCurrency = newValue;
                  });
                },
                isExpanded: true,
                hint: Text('Select a currency', style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black)),
                items: currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency['name'],
                    child: Text(currency['name'], style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black)),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            // Поле для ввода пользователя
            TextField(
              controller: userController,
              decoration: InputDecoration(
                labelText: 'User',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Цвет текста метки
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : const Color.fromARGB(255, 0, 0, 0)), // Цвет рамки
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.purple : Colors.blue), // Цвет рамки при фокусе
                ),
              ),
              enabled: false,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Цвет текста
            ),
            // Поле для ввода количества
            SizedBox(height: 10),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Цвет текста метки
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Цвет рамки
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color.fromARGB(255, 167, 142, 255)), // Цвет рамки при фокусе
                ),
              ),
              onChanged: (value) {
                _updateTotal();
              },
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Цвет текста
            ),
            // Поле для ввода курса обмена
            SizedBox(height: 16),
            TextField(
              controller: exchangeRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Exchange Rate',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Цвет текста метки
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Цвет рамки
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color.fromARGB(255, 167, 142, 255)), // Цвет рамки при фокусе
                ),
              ),
              onChanged: (value) {
                _updateTotal();
              },
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Цвет текста
            ),
            // Поле для автоматического расчета Total
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Цвет текста метки
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.white : Colors.black), // Цвет рамки
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.purple : Colors.blue), // Цвет рамки при фокусе
                ),
              ),
              enabled: false,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black), // Цвет текста
            ),
            SizedBox(height: 20),
            // Центрируем кнопку сохранения
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> updatedEvent = {
                    'id': widget.event['id'],
                    'user': userController.text,
                    'currency': selectedCurrency,
                    'quantity': double.parse(quantityController.text),
                    'exchange_rate': double.parse(exchangeRateController.text),
                    'total': double.parse(totalController.text),
                    'event_type': eventType,
                  };
                  widget.onSave(updatedEvent);
                },
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.purple : const Color.fromARGB(255, 233, 233, 233), // Цвет кнопки
                  foregroundColor: const Color.fromARGB(255, 141, 117, 229)  // Цвет текста на кнопке
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}