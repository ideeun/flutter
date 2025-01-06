import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'tema.dart'; 
import 'package:provider/provider.dart';

class ProfitChartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> processedData;

  ProfitChartScreen({required this.processedData});

  @override
  _ProfitChartScreenState createState() => _ProfitChartScreenState();
}

class _ProfitChartScreenState extends State<ProfitChartScreen>
    with SingleTickerProviderStateMixin<ProfitChartScreen> {

  late AnimationController _glowController;

  int? _highlightedIndex;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);  
    final isDarkMode = themeProvider.isDarkMode;  
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode 
          ? Color.fromARGB(255, 15, 22, 36)
          : Colors.white,
      ),
      backgroundColor: isDarkMode 
        ? Color.fromARGB(255, 15, 22, 36)
        : Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
              'Profit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:isDarkMode ? Colors.white: Colors.black),
            ),
              SizedBox(height: 30),
              Container(
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: widget.processedData
                            .where((data) =>
                                (data['profit'] ?? 0.0) > 0)
                            .map((data) {
                          final value = data['profit'] ?? 0.0;
                          final currency = data['currency'] ?? '';
                          final baseColor = data['color'] ?? ColorManager().getColorForCurrency(currency);
                          data['color'] = baseColor;

                          double total = widget.processedData.fold(0, (sum, item) {
                            return sum + (item['profit'] ?? 0.0);
                          });
                          double percentage = (value / total) * 100;

                          bool isHighlighted = _highlightedIndex != null && _highlightedIndex == widget.processedData.indexOf(data);

                          return PieChartSectionData(
                            value: value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            color: isHighlighted
                                ? baseColor.withOpacity(0.8)
                                : baseColor,
                            radius: _getRadius(value),
                            titleStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:isDarkMode ? Colors.white: Colors.black,
                              shadows: [
                                Shadow(
                                  color: baseColor.withOpacity(0.9),
                                  blurRadius: 10,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            borderSide: BorderSide(
                              color: baseColor.withOpacity(0.5),
                              width: 3,
                            ),
                            gradient: LinearGradient(
                              colors: [
                                baseColor.withOpacity(0.7),
                                baseColor.withOpacity(0.2),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          );
                        }).toList(),
                        centerSpaceRadius: 30,
                        sectionsSpace: 2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: widget.processedData
                    .where((data) =>
                        (data['profit'] ?? 0.0) > 0)
                    .map((data) {
                  final color = data['color'] ?? ColorManager().getColorForCurrency(data['currency']);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _highlightedIndex = widget.processedData.indexOf(data);
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          data['currency'] ?? '',
                          style: TextStyle(color:isDarkMode ? Colors.white: Colors.black),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 100),
              Text(
                'Remaining Quantities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
              ),
              SizedBox(height: 40),
              Container(
                height: 200,
                child: BarChart(
                  BarChartData(
  alignment: BarChartAlignment.spaceAround,
  barGroups: widget.processedData
      .where((data) => (data['buy_quantity'] - data['sell_quantity'] ?? 0) > 0)
      .map((data) {
    final color = data['color'] ?? ColorManager().getColorForCurrency(data['currency']);
    final value = data['buy_quantity'] - data['sell_quantity'] ?? 0;
    return BarChartGroupData(
      x: widget.processedData.indexOf(data),
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }).toList(),
  titlesData: FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: false), // Отключить подписи слева
    ),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        final index = value.toInt();
        if (index >= 0 && index < widget.processedData.length) {
          return Text(
            widget.processedData[index]['currency'] ?? '',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          );
        }
        return SizedBox.shrink();
      },      ),
    ),
  ),
  borderData: FlBorderData(show: false),
  barTouchData: BarTouchData(enabled: true),
),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getRadius(double value) {
    if (value.isFinite) {
      final maxValue = widget.processedData
          .map((e) => (e['profit'] ?? 0.0) as double)
          .reduce(max); 
      return 100 + (value / maxValue * 20);
    }
    return 100;
  }
}

class ColorManager {
  final Map<String, Color> _colorMap = {};
  final Random _random = Random();

  Color _generateHarmoniousColor() {
    final List<int> hueRange = [210, 330]; // Shades from blue to pink
    final double saturation = 0.7; // Saturation (0 to 1)
    final double lightness = 0.6; // Base lightness (0 to 1)

    double hue =
        (_random.nextInt(hueRange[1] - hueRange[0] + 1) + hueRange[0]).toDouble();

    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }

  Color getColorForCurrency(String currency) {
    if (!_colorMap.containsKey(currency)) {
      _colorMap[currency] = _generateHarmoniousColor();
    }
    return _colorMap[currency]!;
  }
}
