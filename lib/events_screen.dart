import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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

  // Функция для получения данных о событиях с API
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/events/'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((event) => event as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  // Функция для удаления события
  Future<void> deleteEvent(int eventId) async {
    final response = await http.delete(Uri.parse('http://127.0.0.1:8000/api/events/$eventId/'));

    if (response.statusCode == 204) {
      setState(() {
        events.removeWhere((event) => event['id'] == eventId);
        selectedEvent = null;  // Сбрасываем выбранное событие
        filterEvents(); // Применяем фильтрацию после удаления
      });
    } else {
      throw Exception('Failed to delete event');
    }
  }

  // Функция для редактирования события
  Future<void> editEvent(Map<String, dynamic> updatedEvent) async {
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/api/events/${updatedEvent['id']}/'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedEvent),
    );

    if (response.statusCode == 200) {
      setState(() {
        int index = events.indexWhere((event) => event['id'] == updatedEvent['id']);
        if (index != -1) {
          events[index] = updatedEvent;
        }
        selectedEvent = updatedEvent;  // Обновляем выбранное событие
        filterEvents(); // Применяем фильтрацию после редактирования
      });
    } else {
      throw Exception('Failed to edit event');
    }
  }

  // Фильтрация событий по выбранной валюте и типу события
  void filterEvents() {
    setState(() {
      filteredEvents = events.where((event) {
        bool matchesCurrency = selectedCurrency == null || selectedCurrency == 'All' || event['currency'] == selectedCurrency;
        bool matchesType = eventTypeFilter == 'All' || event['event_type'] == eventTypeFilter;
        return matchesCurrency && matchesType;
      }).toList();
    });
  }

  // Функция для получения валют
  Future<void> _fetchCurrencies() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/currencies/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        currencies = data.map((currency) {
          return {
            'id': currency['id'],
            'name': currency['name'],
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  // Функция для сортировки по валюте
  void sortByCurrency() {
    setState(() {
      events.sort((a, b) => a['currency'].compareTo(b['currency']));
      filterEvents();  // Применяем фильтрацию после сортировки
    });
  }

  // Функция для сортировки по типу события
  void sortByEventType() {
    setState(() {
      events.sort((a, b) => a['event_type'].compareTo(b['event_type']));
      filterEvents();  // Применяем фильтрацию после сортировки
    });
  }

  @override
  void initState() {
    super.initState();
    fetchEvents().then((eventList) {
      setState(() {
        events = eventList;
        filteredEvents = eventList;
      });
    });
    _fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events Table'),
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
  value: selectedCurrency,
  hint: Text('Select Currency'),
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
      child: Text(currency),
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
                      child: Text(type),
                    );
                  }).toList(),
                ),
              ],
            ),
            // Таблица событий
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Currency')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Exchange Rate')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Event Type')),
                ],
                rows: filteredEvents.map((event) {
                  bool isSelected = selectedEvent != null && selectedEvent!['id'] == event['id'];
                  return DataRow(
                    cells: [
                      DataCell(Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(event['created_at'])))),
                      DataCell(Text(event['user'].toString())),
                      DataCell(Text(event['currency'].toString())),
                      DataCell(Text(event['quantity'].toString())),
                      DataCell(Text(event['exchange_rate'].toString())),
                      DataCell(Text(event['total'].toString())),
                      DataCell(Text(event['event_type'])),
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
          FloatingActionButton(
            onPressed: selectedEvent == null
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditEventScreen(
                          event: selectedEvent!,
                          onSave: (updatedEvent) {
                            editEvent(updatedEvent);
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
          FloatingActionButton(
            onPressed: selectedEvent == null
                ? null
                : () {
                    deleteEvent(selectedEvent!['id']);
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
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/currencies/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        currencies = data.map((currency) {
          return {
            'id': currency['id'],
            'name': currency['name'],
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  @override
  void initState() {
    super.initState();
    quantityController = TextEditingController(text: widget.event['quantity'].toString());
    exchangeRateController = TextEditingController(text: widget.event['exchange_rate'].toString());
    totalController = TextEditingController(text: widget.event['total'].toString());
    userController = TextEditingController(text: widget.event['user'] ?? '');
    selectedCurrency = widget.event['currency'];
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
    return Scaffold(
      appBar: AppBar(title: Text('Edit Event')),
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
              // Строка с кнопками для переключения типа события
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => toggleEventType('SELL'),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        color: eventType == 'SELL' ? Colors.blueAccent : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => toggleEventType('BUY'),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_downward,
                        color: eventType == 'BUY' ? Colors.green : Colors.white,
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
                  border: Border.all(color: Colors.grey, width: 1),
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
                  hint: Text('Select a currency', style: TextStyle(fontSize: 14)),
                  items: currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency['name'],
                      child: Text(currency['name'], style: TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              // Поле для ввода пользователя
              TextField(
                controller: userController,
                decoration: InputDecoration(labelText: 'User'),
                enabled: false,
              ),
              // Поле для ввода количества
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity'),
                onChanged: (value) {
                  _updateTotal();
                },
              ),
              // Поле для ввода курса обмена
              TextField(
                controller: exchangeRateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Exchange Rate'),
                onChanged: (value) {
                  _updateTotal();
                },
              ),
              // Поле для автоматического расчета Total
              TextField(
                controller: totalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Total'),
                enabled: false,
              ),
              SizedBox(height: 20),
              ElevatedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
