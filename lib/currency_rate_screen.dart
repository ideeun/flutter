import 'package:flutter/material.dart';
import 'api_service.dart';  // Импортируем ApiService
import 'tema.dart';
import 'package:provider/provider.dart';

class CurrencyWidget extends StatefulWidget {
  @override
  _CurrencyWidgetState createState() => _CurrencyWidgetState();
}

class _CurrencyWidgetState extends State<CurrencyWidget> {
  late Map<String, dynamic> _currencyData;
  late Map<String, dynamic> _filteredCurrencyData = {};
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _currencyData = {};
    _filteredCurrencyData = {};
    _searchController = TextEditingController();
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
      
      _filteredCurrencyData = Map.from(_currencyData); // Изначально отображаем все данные
    });
  }

  // Функция для поиска валюты
  void _filterCurrencyData(String query) {
  if (mounted) {
    setState(() {
      _filteredCurrencyData = Map.fromEntries(
        _currencyData.entries.where((entry) =>
            entry.key.toLowerCase().contains(query.toLowerCase())) // Фильтруем по ключу (имя валюты)
      );
    });
  }
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CurrencySearchDelegate(
                    currencyData: _currencyData,
                    onQueryChanged: _filterCurrencyData,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: _filteredCurrencyData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredCurrencyData.length,
              itemBuilder: (context, index) {
                String currency = _filteredCurrencyData.keys.elementAt(index);
                String rate = _filteredCurrencyData[currency];
                Color cardColor = isDarkMode
                ? Color.fromARGB(255, 255, 255, 255).withOpacity(0.1)  // Темный цвет для карточки
                : Color.fromARGB(255, 189, 190, 191).withOpacity(0.2);  // Светлый цвет для карточки  // Светлый цвет для карточки

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Округление углов
                  ),
                  color: cardColor,  // Цвет карточки
                  elevation: 0, // Тень для карточки
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Отступы внутри карточки
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Rate: $rate',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CurrencySearchDelegate extends SearchDelegate {
  final Map<String, dynamic> currencyData;
  final Function(String) onQueryChanged;

  CurrencySearchDelegate({required this.currencyData, required this.onQueryChanged});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode
            ? Color.fromARGB(255, 15, 22, 36) // Темный цвет фона для AppBar
            : Color.fromARGB(255, 255, 255, 255),
            iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
             ), // Светлый цвет фона для AppBar
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode
            ? Color.fromARGB(255, 15, 22, 36)  // Темный цвет фона поля поиска
            : Color.fromARGB(255, 255, 255, 255), // Светлый цвет фона поля поиска
        hintStyle: TextStyle(
          color: isDarkMode ? const Color.fromARGB(179, 249, 249, 249) : Colors.black54, // Цвет текста подсказки
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onQueryChanged(query);  // Здесь обновляем состояние
    });
    return _buildSearchResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onQueryChanged(query);  // Здесь обновляем состояние
    });
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final filteredData = currencyData.entries
        .where((entry) => entry.key.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: isDarkMode
          ? Color.fromARGB(255, 15, 22, 36) // Темный фон для всего экрана
          : Color.fromARGB(255, 255, 255, 255), // Светлый фон для всего экрана
      body: filteredData.isEmpty
          ? Center(child: Text('No currencies found.'))
          : ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                String currency = filteredData[index].key;
                String rate = filteredData[index].value;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Color.fromARGB(255, 175, 173, 173).withOpacity(0.1) // Темный фон для карточек
                          : Color.fromARGB(255, 240, 240, 240), // Светлый фон для карточек
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      title: Text(currency.toUpperCase(), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                      subtitle: Text('Rate: $rate', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
                    ),
                  ),
                );
              },
            ),
    );
  }
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';  // Очистка поля поиска
        },
      ),
    ];
  }
}
