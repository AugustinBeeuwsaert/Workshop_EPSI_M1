import 'dart:math';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'chart_data.dart';

class BarChart extends StatelessWidget {
  const BarChart({super.key});

  List<ChartData> _generateRandomData() {
    List<String> months = [];
    DateTime now = DateTime.now();

    for (int i = 1; i <= 3; i++) {
      DateTime month = DateTime(now.year, now.month - i, now.day);
      months.add(monthNames[month.month - 1]);
    }

    Random random = Random();
    List<ChartData> data = months.map((month) {
      return ChartData(
        month: month,
        online: random.nextInt(30),
        inPerson: random.nextInt(20),
        barColor: charts.ColorUtil.fromDartColor(
            Colors.primaries[random.nextInt(Colors.primaries.length)]),
      );
    }).toList();

    return data;
  }

  @override
  Widget build(BuildContext context) {
    List<ChartData> data = _generateRandomData();

    List<charts.Series<ChartData, String>> series = [
      charts.Series(
        id: "Online",
        data: data,
        domainFn: (ChartData series, _) => series.month,
        measureFn: (ChartData series, _) => series.online,
        colorFn: (ChartData series, _) => series.barColor,
      ),
    ];

    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Statistiques des remplacements (3 derniers mois)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: charts.BarChart(
                  series,
                  animate: true,
                  animationDuration: const Duration(seconds: 1),
                  barGroupingType: charts.BarGroupingType.grouped,
                  defaultRenderer: charts.BarRendererConfig(
                    cornerStrategy: const charts.ConstCornerStrategy(30),
                  ),
                  behaviors: [
                    charts.ChartTitle('Mois',
                        behaviorPosition: charts.BehaviorPosition.bottom,
                        titleStyleSpec: const charts.TextStyleSpec(
                            fontSize: 14, color: charts.MaterialPalette.black)),
                    charts.ChartTitle('Remplacements',
                        behaviorPosition: charts.BehaviorPosition.start,
                        titleStyleSpec: const charts.TextStyleSpec(
                            fontSize: 14, color: charts.MaterialPalette.black)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

List<String> monthNames = [
  "Janvier",
  "Février",
  "Mars",
  "Avril",
  "Mai",
  "Juin",
  "Juillet",
  "Août",
  "Septembre",
  "Octobre",
  "Novembre",
  "Décembre"
];
