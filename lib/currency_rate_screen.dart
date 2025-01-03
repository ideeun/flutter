// main.dart или другой файл, где используете виджет
import 'package:flutter/material.dart';
import 'api_service.dart';  // Импортируем ApiService
import 'dart:convert';
import 'tema.dart';
import 'package:provider/provider.dart';

class CurrencyWidget extends StatefulWidget {
  @override
  _CurrencyWidgetState createState() => _CurrencyWidgetState();
}

class _CurrencyWidgetState extends State<CurrencyWidget> {
  late Map<String, dynamic> _currencyData;

  @override
  void initState() {
    super.initState();
    _currencyData = {};
    _loadCurrencyData();
  }

  // Функция для загрузки данных с API
  Future<void> _loadCurrencyData() async {
    final response = await Api.getCurrencyRate(); // Используем ApiService
    setState(() {
      // Извлекаем только валюты и курсы, исключая ненужные поля
      _currencyData = Map.fromEntries(response.entries.where((entry) {
        return !['id', 'created_at', 'updated_at', 'is_current'].contains(entry.key);
      }));
      
      // Также получаем дату created_at для отображения
      print(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);  // Получаем текущую тему
  final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode
            ? Color.fromARGB(255, 15, 22, 36)
            : const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Color.fromARGB(255, 15, 22, 36)
            : const Color.fromARGB(255, 255, 255, 255),
        title: Text("Currency Rates"),
      ),
      body: _currencyData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _currencyData.length,
              itemBuilder: (context, index) {
                String currency = _currencyData.keys.elementAt(index);
                String rate = _currencyData[currency];
                return ListTile(
                  title: Text(currency.toUpperCase()),
                  subtitle: Text('Rate: $rate'),
                );
              },
            ),
    );
  }
}
