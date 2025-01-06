import 'package:flutter/material.dart';
import 'tema.dart'; 
import 'package:provider/provider.dart';
import 'api_service.dart';
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
  double totalRemaining = 0.0;
  int sortColumnIndex = 0;  // Индекс текущего столбца для сортировки
  bool sortAscending = true; 

  Future<void> fetchEvents() async {
    try {
      final eventsData = await Api.fetchEvents();
      print('Events from API: $eventsData'); 
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
  totalRemaining = 0.0;

  groupedEvents.forEach((currency, events) {
    double buyTotal = 0, buyCount = 0;
    double sellTotal = 0, sellCount = 0;
    double remaining = 0;
      // Переменные для хранения количества

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

    remaining = sellTotal - buyTotal;

    totalProfitFromFormula += profit;
    totalBuy += buyTotal;
    totalSell += sellTotal;
    totalRemaining += remaining;

    processedData.add({
      'currency': currency,
      'buy_total': buyTotal,
      'buy_avg': buyAvg,
      'sell_total': sellTotal,
      'sell_avg': sellAvg,
      'profit': profit,
      'remaining': remaining,
      'buy_quantity': buyCount, // Добавлено количество покупок
      'sell_quantity': sellCount, // Добавлено количество продаж
    });
  });

  return processedData;
}

  

void _sort<T>(Comparable<T>? Function(Map<String, dynamic> d) getField, int columnIndex, bool ascending) {
  setState(() {
    events.sort((a, b) {
      final valueA = getField(a);
      final valueB = getField(b);

      if (valueA == null && valueB == null) return 0;
      if (valueA == null) return ascending ? -1 : 1;
      if (valueB == null) return ascending ? 1 : -1;

      return ascending
          ? Comparable.compare(valueA, valueB)
          : Comparable.compare(valueB, valueA);
    });

    sortColumnIndex = columnIndex;
    sortAscending = ascending;
  });
}

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);  
  final isDarkMode = themeProvider.isDarkMode;  

  if (isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  if (errorMessage.isNotEmpty) {
    return Center(child: Text(errorMessage));
  }

  final processedData = processTableData(events);

  return Scaffold(
    backgroundColor: isDarkMode 
        ? Color.fromARGB(255, 15, 22, 36)
        : Colors.white,  
    appBar: AppBar(
      title: Text('Kassa'),
      backgroundColor: isDarkMode 
          ? Color.fromARGB(255, 15, 22, 36)
          : Colors.white, 
      actions: [
        IconButton(
          icon: Icon(Icons.bar_chart),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProfitChartScreen(
                processedData: processedData,
              ),
            ));
          },
        ),
      ],
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
                  sortColumnIndex: sortColumnIndex,
                  sortAscending: sortAscending,
                  columns: [
                    DataColumn(
                      label: Text('Currency', style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: (columnIndex, ascending) {
                        _sort<String>((d) => d['currency'], columnIndex, ascending);
                      },
                    ),
                    DataColumn(
                      label: Text('Buy Total', style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: (columnIndex, ascending) {
                        _sort<num>((d) => d['buy_total'], columnIndex, ascending);
                      },
                    ),
                    DataColumn(
                      label: Text('Buy Avg', style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: (columnIndex, ascending) {
                        _sort<num>((d) => d['buy_avg'], columnIndex, ascending);
                      },
                    ),
                    DataColumn(
                      label: Text('Sell Total', style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: (columnIndex, ascending) {
                        _sort<num>((d) => d['sell_total'], columnIndex, ascending);
                      },
                    ),
                    DataColumn(
                      label: Text('Sell Avg', style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: (columnIndex, ascending) {
                        _sort<num>((d) => d['sell_avg'], columnIndex, ascending);
                      },
                    ),
                    DataColumn(
                      label: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold)),
                      onSort: (columnIndex, ascending) {
                        _sort<num>((d) => d['profit'], columnIndex, ascending);
                      },
                    ),
                    // DataColumn(
                    //   label: Text('Remaining', style: TextStyle(fontWeight: FontWeight.bold)),
                    //   onSort: (columnIndex, ascending) {
                    //     _sort<num>((d) => d['remaining'], columnIndex, ascending);
                    //   },
                    // ),
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
                        // DataCell(Text(data['remaining']?.toStringAsFixed(2) ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
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
                DataColumn(label: Text('Total Profit', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Som', style: TextStyle(fontWeight: FontWeight.bold))),
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
    );
  }
}
      