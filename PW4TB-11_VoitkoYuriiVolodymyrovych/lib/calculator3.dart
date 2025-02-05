import 'package:flutter/material.dart';
import 'dart:math';

class Calculator3 extends StatefulWidget {
  const Calculator3({super.key});

  @override
  Calculator3State createState() => Calculator3State();
}

class Calculator3State extends State<Calculator3> {
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
  'Uk_max': 'Uk_max, кВ',
  'Uv_n': 'Uv_n, кВ',
  'Un_n': 'Un_n, кВ',
  'Snom_t': 'Snom_t, мВ*А',
  'Rc_n': 'Rc_n, Ом',
  'Rc_min': 'Rc_min, Ом',
  'Xc_n': 'Xc_n, Ом',
  'Xc_min': 'Xc_min, Ом',
  'L_l': 'L_l, км',
  'R_0': 'R_0, Ом',
  'X_0': 'X_0, Ом',
};

/// Функція для обчислення результату
String calculate(Map<String, double> values) {
  final Uk_max = values['Uk_max']!;
  final Uv_n = values['Uv_n']!;
  final Un_n = values['Un_n']!;
  final Snom_t = values['Snom_t']!;
  final Rc_n = values['Rc_n']!;
  final Rc_min = values['Rc_min']!;
  final Xc_n = values['Xc_n']!;
  final Xc_min = values['Xc_min']!;
  final L_l = values['L_l']!;
  final R_0 = values['R_0']!;
  final X_0 = values['X_0']!;

  final Xt = Uk_max * pow(Uv_n, 2) / 100 / Snom_t;
  final Rsh = Rc_n;
  final Xsh = Xc_n + Xt;
  final Zsh = sqrt(pow(Rsh, 2) + pow(Xsh, 2));
  final Rsh_min = Rc_min;
  final Xsh_min = Xc_min + Xt;
  final Zsh_min = sqrt(pow(Rsh_min, 2) + pow(Xsh_min, 2));

  final Ish3 = Uv_n * 1000 / sqrt(3.0) / Zsh;
  final Ish2 = Ish3 * sqrt(3.0) / 2;
  final Ish_min3 = Uv_n * 1000 / sqrt(3.0) / Zsh_min;
  final Ish_min2 = Ish_min3 * sqrt(3.0) / 2;

  final kpr = pow(Un_n, 2) / pow(Uv_n, 2);

  final Rsh_n = Rsh * kpr;
  final Xsh_n = Xsh * kpr;
  final Zsh_n = sqrt(pow(Rsh_n, 2) + pow(Xsh_n, 2));
  final Rsh_n_min = Rsh_min * kpr;
  final Xsh_n_min = Xsh_min * kpr;
  final Zsh_n_min = sqrt(pow(Rsh_n_min, 2) + pow(Xsh_n_min, 2));

  final Ish_n3 = Un_n * 1000 / sqrt(3.0) / Zsh_n;
  final Ish_n2 = Ish_n3 * sqrt(3.0) / 2;
  final Ish_n_min3 = Un_n * 1000 / sqrt(3.0) / Zsh_n_min;
  final Ish_n_min2 = Ish_n_min3 * sqrt(3.0) / 2;

  final R_l = L_l * R_0;
  final X_l = L_l * X_0;

  final R_sum_n = R_l + Rsh_n;
  final X_sum_n = X_l + Xsh_n;
  final Z_sum_n = sqrt(pow(R_sum_n, 2) + pow(X_sum_n, 2));

  final R_sum_n_min = R_l + Rsh_n_min;
  final X_sum_n_min = X_l + Xsh_n_min;
  final Z_sum_n_min = sqrt(pow(R_sum_n_min, 2) + pow(X_sum_n_min, 2));

  final I_l_n3 = Un_n * 1000 / sqrt(3.0) / Z_sum_n;
  final I_l_n2 = I_l_n3 * sqrt(3.0) / 2;
  final I_l_n_min3 = Un_n * 1000 / sqrt(3.0) / Z_sum_n_min;
  final I_l_n_min2 = I_l_n_min3 * sqrt(3.0) / 2;

  return "Xт: ${Xt.toStringAsFixed(2)} (Ом)\n"
      "Rш: ${Rsh.toStringAsFixed(2)} (Ом)\n"
      "Xш: ${Xsh.toStringAsFixed(2)} (Ом)\n"
      "Zщ: ${Zsh.toStringAsFixed(2)} (Ом)\n"
      "Rщ_min: ${Rsh_min.toStringAsFixed(2)} (Ом)\n"
      "Xш_min: ${Xsh_min.toStringAsFixed(2)} (Ом)\n"
      "Zш_min: ${Zsh_min.toStringAsFixed(2)} (Ом)\n"
      "I3ш: ${Ish3.toStringAsFixed(2)} (А)\n"
      "I2ш: ${Ish2.toStringAsFixed(2)} (А)\n"
      "I3ш_min: ${Ish_min3.toStringAsFixed(2)} (А)\n"
      "I2ш_min: ${Ish_min2.toStringAsFixed(2)} (А)\n"
      "kпр: ${kpr.toStringAsFixed(2)}\n"
      "Rшн: ${Rsh_n.toStringAsFixed(2)} (Ом)\n"
      "Xшн: ${Xsh_n.toStringAsFixed(2)} (Ом)\n"
      "Zшн: ${Zsh_n.toStringAsFixed(2)} (Ом)\n"
      "Rшн_min: ${Rsh_n_min.toStringAsFixed(2)} (Ом)\n"
      "Xшн_min: ${Xsh_n_min.toStringAsFixed(2)} (Ом)\n"
      "Zшн_min: ${Zsh_n_min.toStringAsFixed(2)} (Ом)\n"
      "I3шн: ${Ish_n3.toStringAsFixed(2)} (А)\n"
      "I2шн: ${Ish_n2.toStringAsFixed(2)} (А)\n"
      "I3шн_min: ${Ish_n_min3.toStringAsFixed(2)} (А)\n"
      "I2шн_min: ${Ish_n_min2.toStringAsFixed(2)} (А)\n"
      "Rл: ${R_l.toStringAsFixed(2)} (Ом)\n"
      "Xл: ${X_l.toStringAsFixed(2)} (Ом)\n"
      "RΣн: ${R_sum_n.toStringAsFixed(2)} (Ом)\n"
      "XΣн: ${X_sum_n.toStringAsFixed(2)} (Ом)\n"
      "ZΣн: ${Z_sum_n.toStringAsFixed(2)} (Ом)\n"
      "RΣн_min: ${R_sum_n_min.toStringAsFixed(2)} (Ом)\n"
      "XΣn_min: ${X_sum_n_min.toStringAsFixed(2)} (Ом)\n"
      "ZΣn_min: ${Z_sum_n_min.toStringAsFixed(2)} (Ом)\n"
      "I3лн: ${I_l_n3.toStringAsFixed(2)} (А)\n"
      "I2лн: ${I_l_n2.toStringAsFixed(2)} (А)\n"
      "I3лн_min: ${I_l_n_min3.toStringAsFixed(2)} (А)\n"
      "I2лн_min: ${I_l_n_min2.toStringAsFixed(2)} (А)\n";
}
