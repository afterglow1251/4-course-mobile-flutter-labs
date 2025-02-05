import 'package:flutter/material.dart';
import 'dart:math';

class Calculator1 extends StatefulWidget {
  const Calculator1({super.key});

  @override
  Calculator1State createState() => Calculator1State();
}

class Calculator1State extends State<Calculator1> {
  final Map<String, TextEditingController> controllers = {
    for (var key in elementLabels.keys) key: TextEditingController()
  };

  ConductorType selectedConductorType = ConductorType.unshielded;
  ConductorMaterial selectedConductorMaterial = ConductorMaterial.aluminum;

  String result = "";
  String errorMessage = "";

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

    final conductorValues = {
      'type': selectedConductorType,
      'material': selectedConductorMaterial,
    };

    setState(() {
      result = calculate(parsedValues, conductorValues);
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
            DropdownButton<ConductorType>(
              value: selectedConductorType,
              items: ConductorType.values.map((material) {
                return DropdownMenuItem(
                  value: material,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      material.displayName,
                      style: TextStyle(fontSize: 16),
                      softWrap: true,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => selectedConductorType = value!),
              isExpanded: true,
            ),
            DropdownButton<ConductorMaterial>(
              value: selectedConductorMaterial,
              items: ConductorMaterial.values.map((material) {
                return DropdownMenuItem(
                  value: material,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      material.displayName,
                      style: TextStyle(fontSize: 16),
                      softWrap: true,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => selectedConductorMaterial = value!),
              isExpanded: true,
            ),
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
  'Unom': 'Unom, кВ',
  'Sm': 'Sm, кВт*А',
  'Ik': 'Ik, кА',
  'P_TP': 'P_TP, кВ*А',
  'Tf': 'Tf, с',
  'Tm': 'Tm, год',
  'Ct': 'Ст',
};

/// Enum типу провідника і значень для вибору
enum ConductorType {
  unshielded('Неізольовані проводи та шини'),
  paperAndRubberCables(
      'Кабелі з паперовою і проводи з гумовою та полівінілхлоридною ізоляцією з жилами'),
  rubberAndPlasticCables('Кабелі з гумовою та пластмасовою ізоляцією з жилами');

  final String displayName;

  const ConductorType(this.displayName);
}

/// Enum матеріалу провідника і значень для вибору
enum ConductorMaterial {
  copper('Мідь'),
  aluminum('Алюміній');

  final String displayName;

  const ConductorMaterial(this.displayName);
}

/// Функція для обчислення результату
String calculate(
    Map<String, double> values, Map<String, dynamic> conductorValues) {
  double Unom = values['Unom']!;
  double Sm = values['Sm']!;
  double Ik = values['Ik']!;
  double Tf = values['Tf']!;
  double Tm = values['Tm']!;
  double Ct = values['Ct']!;

  ConductorType conductorType = conductorValues['type'] as ConductorType;
  ConductorMaterial conductorMaterial =
      conductorValues['material'] as ConductorMaterial;

  double Im = Sm / (2.0 * sqrt(3.0) * Unom);
  double Im_pa = 2 * Im;
  double jek = getJek(conductorType, conductorMaterial, Tm);
  double Sek = jek > 0.0 ? Im / jek : 0.0;
  double Smin = Ik * 1000 * sqrt(Tf) / Ct;

  return "Iм: ${Im.toStringAsFixed(2)} (A)\n"
      "Iм.па: ${Im_pa.toStringAsFixed(2)} (A)\n"
      "Sек: ${Sek.toStringAsFixed(2)} (мм²)\n"
      "Smin: ${Smin.toStringAsFixed(2)} (мм²)";
}

/// Функція для отримання Jек
double getJek(ConductorType type, ConductorMaterial material, double Tm) {
  final Map<ConductorType,
      Map<ConductorMaterial, List<MapEntry<RangeValues, double>>>> jekValues = {
    ConductorType.unshielded: {
      ConductorMaterial.copper: [
        MapEntry(RangeValues(1000, 3000), 2.5),
        MapEntry(RangeValues(3000, 5000), 2.1),
        MapEntry(RangeValues(5000, double.infinity), 1.8),
      ],
      ConductorMaterial.aluminum: [
        MapEntry(RangeValues(1000, 3000), 1.3),
        MapEntry(RangeValues(3000, 5000), 1.1),
        MapEntry(RangeValues(5000, double.infinity), 1.0),
      ],
    },
    ConductorType.paperAndRubberCables: {
      ConductorMaterial.copper: [
        MapEntry(RangeValues(1000, 3000), 3.0),
        MapEntry(RangeValues(3000, 5000), 2.5),
        MapEntry(RangeValues(5000, double.infinity), 2.0),
      ],
      ConductorMaterial.aluminum: [
        MapEntry(RangeValues(1000, 3000), 1.6),
        MapEntry(RangeValues(3000, 5000), 1.4),
        MapEntry(RangeValues(5000, double.infinity), 1.2),
      ],
    },
    ConductorType.rubberAndPlasticCables: {
      ConductorMaterial.copper: [
        MapEntry(RangeValues(1000, 3000), 3.5),
        MapEntry(RangeValues(3000, 5000), 3.1),
        MapEntry(RangeValues(5000, double.infinity), 2.7),
      ],
      ConductorMaterial.aluminum: [
        MapEntry(RangeValues(1000, 3000), 1.9),
        MapEntry(RangeValues(3000, 5000), 1.7),
        MapEntry(RangeValues(5000, double.infinity), 1.6),
      ],
    },
  };

  return jekValues[type]?[material]
          ?.firstWhere(
            (entry) => Tm >= entry.key.start && Tm <= entry.key.end,
            orElse: () => MapEntry(RangeValues(0, 0), 0),
          )
          .value ??
      0.0;
}
