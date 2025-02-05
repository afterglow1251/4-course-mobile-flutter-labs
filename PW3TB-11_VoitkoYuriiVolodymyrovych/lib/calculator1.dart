import 'package:flutter/material.dart';
import 'dart:math';

/// Мапа для елементів і назв інпутів
const Map<String, String> elementLabels = {
  'Pc': 'Середньодобова потужність, (МВт)',
  'Sigma': 'Cередньоквадратичне відхилення, (МВт)',
  'B': 'Вартість електроенергії, (грн/кВт*год)',
};

/// Функція для обчислення результату
String calculate(Map<String, double> values) {
  final Pc = values['Pc']!;
  final Sigma = values['Sigma']!;
  final B = values['B']!;

  // Частка енергії, що генерується без небалансів
  final balancedEnergyShare = integrateEnergyShare(
    function: (power) => calculateNormalDistribution(power, Pc, Sigma),
    averagePower: Pc,
    totalSteps: 10000,
  );

  final revenue = Pc * 24 * balancedEnergyShare * B;
  final fine = Pc * 24 * (1 - balancedEnergyShare) * B;
  final profit = revenue - fine;

  return 'Дохід: ${revenue.toStringAsFixed(1)} (тис. грн)\n'
      'Штраф: ${fine.toStringAsFixed(1)} (тис. грн)\n'
      'Прибуток${profit < 0 ? ' (збиток)' : ''}: ${profit.toStringAsFixed(1)} (тис. грн)';
}

/// Обчислення значення функції нормального розподілу для заданої потужності
double calculateNormalDistribution(
    double power, double averagePower, double standardDeviation) {
  return (1 / (standardDeviation * sqrt(2 * pi))) *
      exp(-(pow((power - averagePower), 2)) / (2 * pow(standardDeviation, 2)));
}

/// Обчислення інтегралу функції нормального розподілу для визначення частки енергії
double integrateEnergyShare({
  required Function(double) function,
  required double averagePower,
  required int totalSteps,
  double deviationFactor = 0.05,
}) {
  final lowerLimit = averagePower * (1 - deviationFactor);
  final upperLimit = averagePower * (1 + deviationFactor);
  final stepSize = (upperLimit - lowerLimit) / totalSteps;
  double result = 0.0;

  for (int i = 0; i < totalSteps; i++) {
    final currentPoint = lowerLimit + i * stepSize;
    final nextPoint = currentPoint + stepSize;
    result += 0.5 * (function(currentPoint) + function(nextPoint)) * stepSize;
  }

  return result;
}

class Calculator1 extends StatefulWidget {
  const Calculator1({super.key});

  @override
  Calculator1State createState() => Calculator1State();
}

class Calculator1State extends State<Calculator1> {
  final Map<String, TextEditingController> controllers = {
    for (var key in elementLabels.keys) key: TextEditingController(),
  };

  String result = '';
  String errorMessage = '';

  void onCalculate() {
    final values = controllers.map(
            (key, controller) => MapEntry(key, double.tryParse(controller.text)));

    if (values.values.any((v) => v == null)) {
      setState(() {
        errorMessage = 'Будь ласка, заповніть всі поля коректно.';
        result = '';
      });
      return;
    }

    final parsedValues = values.map((key, value) => MapEntry(key, value!));
    final calculationResult = calculate(parsedValues);

    setState(() {
      result = calculationResult;
      errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Розрахунок енергетичної потужності'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...controllers.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: TextField(
                controller: entry.value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                  elementLabels[entry.key] ?? entry.key.toUpperCase(),
                  border: OutlineInputBorder(),
                ),
              ),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCalculate,
                child: const Text('Обчислити'),
              ),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (result.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  result,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
