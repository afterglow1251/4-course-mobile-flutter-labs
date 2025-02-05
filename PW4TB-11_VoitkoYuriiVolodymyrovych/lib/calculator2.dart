import 'package:flutter/material.dart';
import 'dart:math';

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
      (key, controller) => MapEntry(key, double.tryParse(controller.text)),
    );

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
            ...elementLabels.keys.map(
              (key) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: controllers[key],
                  decoration: InputDecoration(
                    labelText: elementLabels[key],
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
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
  "Ucn": "Ucn, кВ",
  "Sk": "Sk, МВ*А",
  "Uk_perc": "Uk_perc, кВ",
  "S_nom_t": "S_nom_t, МВ*А",
};

/// Функція для обчислення результату
String calculate(Map<String, double> values) {
  final Ucn = values["Ucn"]!;
  final Sk = values["Sk"]!;
  final Uk_perc = values["Uk_perc"]!;
  final S_nom_t = values["S_nom_t"]!;

  final Xc = pow(Ucn, 2) / Sk;
  final Xt = Uk_perc * pow(Ucn, 2) / S_nom_t / 100;
  final X_sum = Xc + Xt;
  final Ip0 = Ucn / (sqrt(3.0) * X_sum);

  return "Xс: ${Xc.toStringAsFixed(2)} (Ом)\n"
      "Xт: ${Xt.toStringAsFixed(2)} (Ом)\n"
      "XΣ: ${X_sum.toStringAsFixed(2)} (Ом)\n"
      "Iп0: ${Ip0.toStringAsFixed(2)} (кА)";
}
