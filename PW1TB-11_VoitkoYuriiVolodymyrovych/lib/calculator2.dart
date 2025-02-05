import 'package:flutter/material.dart';

/// Мапа назв елементів і назв інпутів
const Map<String, String> elementLabels = {
  'hp': 'Водень (H)%',
  'cp': 'Вуглець (C)%',
  'sp': 'Сірка (S)%',
  'op': 'Кисень (O)%',
  'wp': 'Волога (W)%',
  'ap': 'Зола (A)%',
  'vp': 'Ванадій (V) мг/кг',
  'qr': 'Q мазуту (Q Fuel oil) МДж/кг',
};

/// Функція для обчислення результату
String calculate(Map<String, double> values) {
  final w = values['wp']!;
  final a = values['ap']!;
  final qFO = values['qr']!;
  final krs = (100 - w - a) / 100;

  final hWork = values['hp']! * krs;
  final cWork = values['cp']! * krs;
  final sWork = values['sp']! * krs;
  final oWork = values['op']! * krs;
  final vWork = values['vp']! * (100 - w) / 100;

  final qR = qFO * krs - 0.025 * w;

  return 'Склад робочої маси мазуту:\n'
      'CP: ${cWork.toStringAsFixed(2)}%\n'
      'HP: ${hWork.toStringAsFixed(2)}%\n'
      'SP: ${sWork.toStringAsFixed(2)}%\n'
      'OP: ${oWork.toStringAsFixed(2)}%\n'
      'AP: ${a.toStringAsFixed(2)}%\n'
      'VP: ${vWork.toStringAsFixed(2)} (мг/кг)\n\n'
      'Нижча теплота згоряння: ${qR.toStringAsFixed(2)} (МДж/кг)';
}

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
