import 'package:flutter/material.dart';

class Calculator2 extends StatefulWidget {
  const Calculator2({super.key});

  @override
  Calculator2State createState() => Calculator2State();
}

class Calculator2State extends State<Calculator2> {
  final Map<String, TextEditingController> controllers = {
    for (var key in elementLabels.keys) key: TextEditingController()
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...controllers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: entry.value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: elementLabels[entry.key],
                    border: OutlineInputBorder(),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
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

/// Мапа назв елементів і назв інпутів
const Map<String, String> elementLabels = {
  'omega': 'Omega',
  'tV': 'tS',
  'pM': 'pM',
  'tM': 'tM',
  'kP': 'kP',
  'zPerA': 'zPerA',
  'zPerP': 'zPerP',
};

/// Функція для обчислення результату
String calculate(Map<String, double> values) {
  final omega = values['omega']!;
  final tV = values['tV']!;
  final pM = values['pM']!;
  final tM = values['tM']!;
  final kP = values['kP']!;
  final zPerA = values['zPerA']!;
  final zPerP = values['zPerP']!;

  final mWnedA = omega * tV * pM * tM;
  final mWnedP = kP * pM * tM;
  final mZper = zPerA * mWnedA + zPerP * mWnedP;

  return 'M(Wнед.а): ${mWnedA.toStringAsFixed(2)} (кВт * год)\n'
      'M(Wед.п): ${mWnedP.toStringAsFixed(2)} (кВт * год)\n'
      'M(Зпер): ${mZper.toStringAsFixed(2)} (грн)';
}
