import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'tema.dart'; 
import 'package:provider/provider.dart';
import 'api_servic.dart';
import 'dia.dart';


class CashScreen extends StatefulWidget {
  @override
  _CashScreenState createState() => _CashScreenState();
}

class _CashScreenState extends State<CashScreen> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  String errorMessage = '';
  double totalProfitFromFormula = 0.0;
  double totalBuy = 0.0;
  double totalSell = 0.0;
  double totalRemaining = 0.0; // Общее количество оставшихся единиц

  Future<void> fetchEvents() async {
    try {
      final eventsData = await Api.fetchEvents(); // Используем метод API
      setState(() {
        events = eventsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Ошибка загрузки данных: $e';
      });
    }
  }

  List<Map<String, dynamic>> processTableData(List<Map<String, dynamic>> events) {
    Map<String, List<Map<String, dynamic>>> groupedEvents = {};
    for (var event in events) {
      String currency = event['currency'];
      if (!groupedEvents.containsKey(currency)) {
        groupedEvents[currency] = [];
      }
      groupedEvents[currency]?.add(event);
    }

    List<Map<String, dynamic>> processedData = [];
    totalBuy = 0;
    totalSell = 0;
    totalProfitFromFormula = 0.0;
    totalRemaining = 0.0; // Сброс значения остатка

    groupedEvents.forEach((currency, events) {
      double buyTotal = 0, buyCount = 0;
      double sellTotal = 0, sellCount = 0;
      double remaining = 0;

      for (var event in events) {
        double quantity = double.tryParse(event['quantity'].toString()) ?? 0.0;
        double total = double.tryParse(event['total'].toString()) ?? 0.0;

        if (event['event_type'] == 'BUY') {
          buyTotal += total;
          buyCount += quantity;
        } else if (event['event_type'] == 'SELL') {
          sellTotal += total;
          sellCount += quantity;
        }
      }

      double buyAvg = buyCount > 0 ? buyTotal / buyCount : 0;
      double sellAvg = sellCount > 0 ? sellTotal / sellCount : 0;
      double profit = (sellAvg - buyAvg) * (sellCount <= buyCount ? sellCount : buyCount);

      remaining = buyCount - sellCount;

      totalProfitFromFormula += profit;
      totalBuy += buyTotal;
      totalSell += sellTotal;
      totalRemaining += remaining; // Добавляем остаток в общую сумму

      processedData.add({
        'currency': currency,
        'buy_total': buyTotal,
        'buy_avg': buyAvg,
        'sell_total': sellTotal,
        'sell_avg': sellAvg,
        'profit': profit,
        'remaining': remaining,
      });
    });

    return processedData;
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);  // Получаем текущую тему
  final isDarkMode = themeProvider.isDarkMode;  // Проверка на темную тему

  if (isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  if (errorMessage.isNotEmpty) {
    return Center(child: Text(errorMessage));
  }

  final processedData = processTableData(events);

  return Scaffold(
    backgroundColor: isDarkMode ? const Color.fromARGB(255, 6, 16, 38) : Colors.white,  // Фон для Scaffold
    appBar: AppBar(
      title: Text('Kassa'),
      backgroundColor: isDarkMode ? const Color.fromARGB(255, 6, 16, 38) : const Color.fromARGB(255, 255, 255, 255),  // Фон AppBar
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Currency', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Buy Total', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Buy Avg', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sell Total', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Sell Avg', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Remaining', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: processedData.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(Text(data['currency'] ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                        DataCell(Text(data['buy_total']?.toStringAsFixed(2) ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                        DataCell(Text(data['buy_avg']?.toStringAsFixed(2) ?? '-', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                        DataCell(Text(data['sell_total']?.toStringAsFixed(2) ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                        DataCell(Text(data['sell_avg']?.toStringAsFixed(2) ?? '-', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                        DataCell(Text(
                          data['profit']?.toStringAsFixed(2) ?? '',
                          style: TextStyle(
                            color: data['profit'] >= 0
                                ? const Color.fromARGB(255, 17, 200, 105)
                                : const Color.fromARGB(255, 212, 65, 16),
                          ),
                        )),
                        DataCell(Text(data['remaining']?.toStringAsFixed(2) ?? '0', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Remaining', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: [
              DataRow(
                cells: [
                  DataCell(Text(
                    totalProfitFromFormula.toStringAsFixed(2),
                    style: TextStyle(
                      color: totalProfitFromFormula >= 0
                          ? const Color.fromARGB(255, 17, 200, 105)
                          : const Color.fromARGB(255, 212, 65, 16),
                    ),
                  )),
                  DataCell(Text(totalRemaining.toStringAsFixed(2), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    floatingActionButton: FloatingActionButton(
  onPressed: () {
    final processedData = processTableData(events);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProfitChartScreen(
        processedData: processedData,
      ),
    ));
  },
  backgroundColor: isDarkMode ? const Color.fromARGB(255, 17, 100, 200) : Colors.blue,
  child: const Icon(Icons.bar_chart),
),
  );
}
}