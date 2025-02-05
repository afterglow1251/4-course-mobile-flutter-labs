import 'package:flutter/material.dart';

/// Мапа назв елементів і назв інпутів
const Map<String, String> elementLabels = {
  'hp': 'Водень (H)%',
  'cp': 'Вуглець (C)%',
  'sp': 'Сірка (S)%',
  'np': 'Азот (N)%',
  'op': 'Кисень (O)%',
  'wp': 'Волога (W)%',
  'ap': 'Зола (A)%'
};

/// Функція для обчислення результату
String calculate(Map<String, double> values) {
  final wp = values['wp']!;
  final krs = 100 / (100 - wp);
  final krg = 100 / (100 - wp - values['ap']!);

  final dryMass = values.map((key, value) => MapEntry(key, value * krs));
  final combustibleMass =
      values.map((key, value) => MapEntry(key, value * krg));

  final qph = (339 * values['cp']! +
          1030 * values['hp']! -
          108.8 * (values['op']! - values['sp']!) -
          25 * wp) /
      1000;
  final qch = (qph + 0.025 * wp) * krs;
  final qgh = (qph + 0.025 * wp) * krg;

  return 'Коефіцієнт переходу від робочої до сухої маси:\n${krs.toStringAsFixed(2)}\n\n'
      'Коефіцієнт переходу від робочої до горючої маси:\n${krg.toStringAsFixed(2)}\n\n'
      'Склад сухої маси палива:\n'
      'HС: ${dryMass['hp']?.toStringAsFixed(2)}%\n'
      'CС: ${dryMass['cp']?.toStringAsFixed(2)}%\n'
      'SС: ${dryMass['sp']?.toStringAsFixed(2)}%\n'
      'NС: ${dryMass['np']?.toStringAsFixed(2)}%\n'
      'OС: ${dryMass['op']?.toStringAsFixed(2)}%\n'
      'AС: ${dryMass['ap']?.toStringAsFixed(2)}%\n\n'
      'Склад горючої маси палива:\n'
      'HГ: ${combustibleMass['hp']?.toStringAsFixed(2)}%\n'
      'CГ: ${combustibleMass['cp']?.toStringAsFixed(2)}%\n'
      'SГ: ${combustibleMass['sp']?.toStringAsFixed(2)}%\n'
      'NГ: ${combustibleMass['np']?.toStringAsFixed(2)}%\n'
      'OГ: ${combustibleMass['op']?.toStringAsFixed(2)}%\n\n'
      'Нижча теплота згоряння для робочої маси:\n${qph.toStringAsFixed(4)} (МДж/кг)\n\n'
      'Нижча теплота згоряння для сухої маси:\n${qch.toStringAsFixed(4)} (МДж/кг)\n\n'
      'Нижча теплота згоряння для горючої маси:\n${qgh.toStringAsFixed(4)} (МДж/кг)';
}

class Calculator1 extends StatefulWidget {
  const Calculator1({super.key});

  @override
  Calculator1State createState() => Calculator1State();
}

class Calculator1State extends State<Calculator1> {
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
        result = '';
        errorMessage = 'Будь ласка, заповніть всі поля коректно.';
      });
      return;
    }

    final total = values.values.reduce((sum, value) => sum! + value!);
    if (total != 100.0) {
      setState(() {
        result = '';
        errorMessage = 'Сума всіх компонентів повинна складати 100%';
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
