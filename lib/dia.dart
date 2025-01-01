import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ProfitChartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> processedData;

  ProfitChartScreen({required this.processedData});

  @override
  _ProfitChartScreenState createState() => _ProfitChartScreenState();
}

class _ProfitChartScreenState extends State<ProfitChartScreen> {
  bool showRemaining = false; // To toggle between profit and remaining values

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
              showRemaining = !showRemaining; // Toggle between profit and remaining
            });
          },
          child: Column(
            children: [
              Text(showRemaining ?
                 'Reimaninig':'Profit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: widget.processedData
                        .where((data) => (data[showRemaining ? 'remaining' : 'profit'] ?? 0.0) > 0) // Filter based on profit or remaining
                        .map((data) {
                          final value = data[showRemaining ? 'remaining' : 'profit'] ?? 0.0;
                          final currency = data['currency'] ?? '';
                          final baseColor = data['color'] ?? ColorManager().getColorForCurrency(currency);
                          data['color'] = baseColor;

                          // Calculate the radius based on the value (profit or remaining)
                          double radius = _getRadius(value);

                          // Calculate opacity based on the distance from the center (i.e., based on the radius)
                          // double opacity = _getOpacity(radius);

                          return PieChartSectionData(
                            value: value,
                            title: '\$${value.toStringAsFixed(2)}',
                            color: baseColor,
                            radius: radius,
                            titleStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        })
                        .toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Column(
                children: widget.processedData
                    .where((data) => (data[showRemaining ? 'remaining' : 'profit'] ?? 0.0) > 0) // Filter based on profit or remaining
                    .map((data) {
                      final color = data['color'] ?? ColorManager().getColorForCurrency(data['currency']);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: color, // Use the same color as in the chart
                              ),
                              SizedBox(width: 8),
                              Text(
                                data['currency'] ?? '',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          Text(
                            '\$${(data[showRemaining ? 'remaining' : 'profit'] ?? 0.0).toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      );
                    })
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Calculate opacity based on the distance to the center (the closer to the center, the more transparent)
  // double _getOpacity(double radius) {
  //   final maxRadius = 160.0; // Max radius of the pie chart
  //   final minOpacity = 0.2;
  //   final maxOpacity = 1.0;

  //   // The closer the radius is to the center, the more transparent it becomes
  //   double opacity = maxOpacity - ((radius / maxRadius) * (maxOpacity - minOpacity));
  //   return opacity.clamp(minOpacity, maxOpacity);
  // }

  // Adjust the radius based on the value (profit or remaining), to create a smooth circular effect
  double _getRadius(double value) {
    final maxValue = widget.processedData.map((e) => (e['profit'] ?? 0.0) as double).reduce(max);
    return 100 + (value / maxValue * 60); // Radius increases as value increases
  }
}


class ColorManager {
  final Map<String, Color> _colorMap = {};
  final Random _random = Random();

  Color _generateHarmoniousColor() {
    final List<int> hueRange = [210, 330]; // Shades from blue to pink
    final double saturation = 0.7; // Saturation (0 to 1)
    final double lightness = 0.6; // Base lightness (0 to 1)

    double hue = (_random.nextInt(hueRange[1] - hueRange[0] + 1) + hueRange[0]).toDouble();

    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }

  Color getColorForCurrency(String currency) {
    if (!_colorMap.containsKey(currency)) {
      _colorMap[currency] = _generateHarmoniousColor();
    }
    return _colorMap[currency]!;
  }
}
