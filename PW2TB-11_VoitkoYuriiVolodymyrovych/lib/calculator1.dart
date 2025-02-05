import 'package:flutter/material.dart';

/// Мапа для елементів і назв інпутів
const Map<String, String> elementLabels = {
  'Q_i_r': 'Q_i_r',
  'a_vun': 'a_vun',
  'A_r': 'A_r',
  'G_vun': 'G_vun',
  'eta_z_y': 'eta_z_y',
  'k_tv_s': 'k_tv_s',
  'B': 'B',
};

/// Функція для обчислення результату
String calculate(Map<String, double> values) {
  final qir = values['Q_i_r']!;
  final avun = values['a_vun']!;
  final ar = values['A_r']!;
  final gvun = values['G_vun']!;
  final etazy = values['eta_z_y']!;
  final kTVS = values['k_tv_s']!;
  final b = values['B']!;

  final kTV = (1e6 / qir) * (avun * (ar / (100 - gvun)) * (1 - etazy)) + kTVS;

  final etv = 1e-6 * kTV * qir * b;

  return 'Показник емісії: ${kTV.toStringAsFixed(2)} (г/ГДж)\n'
      'Валовий викид: ${etv.toStringAsFixed(2)} (т)';
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
