import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> events = [];
  Map<String, dynamic>? selectedEvent;

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
      });
    } else {
      throw Exception('Failed to edit event');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
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
            // Таблица событий
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No events found.'));
                } else {
                  final events = snapshot.data ?? [];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Currency')),
                        DataColumn(label: Text('Quantity')),
                        DataColumn(label: Text('Exchange Rate')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('Event Type')),
                      ],
                      rows: events.map((event) {
                        return DataRow(
                          selected: selectedEvent != null && selectedEvent!['id'] == event['id'],
                          onSelectChanged: (selected) {
                            setState(() {
                              selectedEvent = selected! ? event : null;
                            });
                          },
                          cells: [
                            DataCell(Text(event['user'].toString())),
                            DataCell(Text(event['currency'].toString())),
                            DataCell(Text(event['quantity'].toString())),
                            DataCell(Text(event['exchange_rate'].toString())),
                            DataCell(Text(event['total'].toString())),
                            DataCell(Text(event['event_type'])),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            // Кнопки для редактирования и удаления
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: selectedEvent == null
                      ? null
                      : () {
                          // Редактирование
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
                  child: Text('Edit Event'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: selectedEvent == null
                      ? null
                      : () {
                          // Удаление
                          deleteEvent(selectedEvent!['id']);
                          setState(() {
                            selectedEvent = null;
                          });
                        },
                  child: Text('Delete Event'),
                ),
              ],
            ),
          ],
        ),
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
  late TextEditingController userController;
  late TextEditingController currencyController;
  late TextEditingController quantityController;
  late TextEditingController exchangeRateController;
  late TextEditingController totalController;
  late TextEditingController eventTypeController;

  @override
  void initState() {
    super.initState();
    userController = TextEditingController(text: widget.event['user'].toString());
    currencyController = TextEditingController(text: widget.event['currency'].toString());
    quantityController = TextEditingController(text: widget.event['quantity'].toString());
    exchangeRateController = TextEditingController(text: widget.event['exchange_rate'].toString());
    totalController = TextEditingController(text: widget.event['total'].toString());
    eventTypeController = TextEditingController(text: widget.event['event_type']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: userController,
              decoration: InputDecoration(labelText: 'User'),
            ),
            TextField(
              controller: currencyController,
              decoration: InputDecoration(labelText: 'Currency'),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: exchangeRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Exchange Rate'),
            ),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total'),
            ),
            TextField(
              controller: eventTypeController,
              decoration: InputDecoration(labelText: 'Event Type'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> updatedEvent = {
                  'id': widget.event['id'],
                  'user': userController.text,
                  'currency': currencyController.text,
                  'quantity': double.parse(quantityController.text),
                  'exchange_rate': double.parse(exchangeRateController.text),
                  'total': double.parse(totalController.text),
                  'event_type': eventTypeController.text,
                };
                widget.onSave(updatedEvent);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
