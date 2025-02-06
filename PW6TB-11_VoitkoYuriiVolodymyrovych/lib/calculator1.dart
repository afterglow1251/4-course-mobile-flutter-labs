import 'package:flutter/material.dart';
import 'dart:math';

List<Equipment> equipmentList = [
  Equipment(
      "Шліфувальний верстат", "0.92", "0.9", "0.38", "4", "20", "0.15", "1.33"),
  Equipment(
      "Свердлильний верстат", "0.92", "0.9", "0.38", "2", "14", "0.12", "1"),
  Equipment(
      "Фугувальний верстат", "0.92", "0.9", "0.38", "4", "42", "0.15", "1.33"),
  Equipment("Циркулярна пила", "0.92", "0.9", "0.38", "1", "36", "0.3", "1.52"),
  Equipment("Прес", "0.92", "0.9", "0.38", "1", "20", "0.5", "0.75"),
  Equipment(
      "Полірувальний верстат", "0.92", "0.9", "0.38", "1", "40", "0.2", "1"),
  Equipment("Фрезерний верстат", "0.92", "0.9", "0.38", "2", "32", "0.2", "1"),
  Equipment("Вентилятор", "0.92", "0.9", "0.38", "1", "20", "0.65", "0.75"),
];

class Calculator1 extends StatefulWidget {
  const Calculator1({super.key});

  @override
  Calculator1State createState() => Calculator1State();
}

class Calculator1State extends State<Calculator1> {
  double totalNominalPowerWithCoefficient = 0.0;
  String loadCoefficient2 = "0.7";
  String loadCoefficient1 = "1.25";
  String groupUtilizationCoefficient = "";
  String effectiveEquipmentCount = "";
  String totalDeptUtilizationCoef = "";
  String effectiveEquipmentDeptAmount = "";
  String totalActivePowerDept = "";
  String totalReactivePowerDept = "";
  String totalApparentPowerDept = "";
  String totalCurrentDept = "";
  String totalActivePowerDept1 = "";
  String totalReactivePowerDept1 = "";
  String totalApparentPowerDept1 = "";
  String totalCurrentDept1 = "";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                equipmentList.add(Equipment());
              });
            },
            child: const Text("Додати ЕП"),
          ),
          const SizedBox(height: 16),
          Column(
            children: equipmentList.map((equipment) {
              return EquipmentInputsShape(
                equipment: equipment,
                onUpdate: (updatedEquipment) {
                  setState(() {
                    equipmentList[equipmentList.indexOf(equipment)] =
                        updatedEquipment;
                  });
                },
              );
            }).toList(),
          ),
          TextField(
            controller: TextEditingController(text: loadCoefficient1),
            onChanged: (value) {
              setState(() {
                loadCoefficient1 = value;
              });
            },
            decoration: const InputDecoration(
              labelText: "Розрахунковий коеф. активної потужності (Kr)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: loadCoefficient2),
            onChanged: (value) {
              setState(() {
                loadCoefficient2 = value;
              });
            },
            decoration: const InputDecoration(
              labelText: "Розрахунковий коеф. активної потужності (Kr2)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: calculateAll,
              child: const Text('Обчислити'),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Груповий коефіцієнт використання: $groupUtilizationCoefficient\n"
              "Ефективна кількість ЕП: $effectiveEquipmentCount",
              textAlign: TextAlign
                  .left,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Груповий коефіцієнт використання: $groupUtilizationCoefficient\n"
              "Ефективна кількість ЕП: $effectiveEquipmentCount",
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Груповий коефіцієнт використання: $groupUtilizationCoefficient\n"
              "Ефективна кількість ЕП: $effectiveEquipmentCount",
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Розрахункове активне навантаження: $totalActivePowerDept (кВт)\n"
              "Розрахункове реактивне навантаження: $totalReactivePowerDept (квар)\n"
              "Повна потужність: $totalApparentPowerDept (кВ*А)\n"
              "Розрахунковий груповий струм ШР1: $totalCurrentDept (А)\n"
              "Коефіцієнт використання цеху в цілому: $totalDeptUtilizationCoef\n"
              "Ефективна кількість ЕП цеху в цілому: $effectiveEquipmentDeptAmount",
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            alignment: Alignment.centerLeft, // Вирівнювання по лівому краю
            child: Text(
              "Розрахункове активне навантаження на шинах 0,38 кВ ТП: $totalActivePowerDept1 (кВт)\n"
              "Розрахункове реактивне навантаження на шинах 0,38 кВ ТП: $totalReactivePowerDept1 (квар)\n"
              "Повна потужність на шинах 0,38 кВ ТП: $totalApparentPowerDept1 (кВ*А)\n"
              "Розрахунковий груповий струм на шинах 0,38 кВ ТП: $totalCurrentDept1 (А)",
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  void calculateAll() {
    double totalNominalPowerCoeffProduct = 0.0;
    double totalNominalPowerProduct = 0.0;
    double totalNominalPowerSquared = 0.0;

    for (var equipment in equipmentList) {
      double quantity = double.tryParse(equipment.quantity) ?? 0.0;
      double nominalPower = double.tryParse(equipment.nominalPower) ?? 0.0;
      equipment.totalNominalPower = (quantity * nominalPower).toString();
      double currentPower = double.tryParse(equipment.totalNominalPower) ??
          0.0 /
              (sqrt(3.0) *
                  (double.tryParse(equipment.voltage) ?? 0.0) *
                  (double.tryParse(equipment.powerFactor) ?? 0.0) *
                  (double.tryParse(equipment.efficiency) ?? 0.0));
      equipment.current = currentPower.toString();

      totalNominalPowerCoeffProduct +=
          (double.tryParse(equipment.totalNominalPower) ?? 0.0) *
              (double.tryParse(equipment.usageCoefficient) ?? 0.0);
      totalNominalPowerProduct +=
          double.tryParse(equipment.totalNominalPower) ?? 0.0;
      totalNominalPowerSquared += quantity * pow(nominalPower, 2);
    }

    totalNominalPowerWithCoefficient = totalNominalPowerCoeffProduct;

    // Груповий коефіцієнт використання
    double groupUtilization =
        totalNominalPowerCoeffProduct / totalNominalPowerProduct;
    groupUtilizationCoefficient = groupUtilization.toString();

    // Ефективна кількість ЕП
    double effectiveEquipment = (totalNominalPowerProduct *
            totalNominalPowerProduct /
            totalNominalPowerSquared)
        .ceilToDouble();
    effectiveEquipmentCount = effectiveEquipment.toString();

    // Потужність та струм
    double utilizationCoef =
        double.tryParse(groupUtilizationCoefficient) ?? 0.0;
    double loadCoef = double.tryParse(loadCoefficient1) ?? 0.0;

    double voltageLevel = 0.38;

    double referencePower = 26.0; // за 7 варіантом
    double tanPhi = 1.62; // за 7 варіантом

    double activePower = loadCoef * totalNominalPowerWithCoefficient;
    double reactivePower = utilizationCoef * referencePower * tanPhi;
    double apparentPower = sqrt(pow(activePower, 2) + pow(reactivePower, 2));
    double groupCurrent = activePower / voltageLevel;

    totalActivePowerDept = activePower.toString();
    totalReactivePowerDept = reactivePower.toString();
    totalApparentPowerDept = apparentPower.toString();
    totalCurrentDept = groupCurrent.toString();

    totalDeptUtilizationCoef = (752.0 / 2330.0).toString();
    effectiveEquipmentDeptAmount = (2330.0 * 2330.0 / 96399.0).toString();

    // Потужність та струм на шинах
    double utilizationCoef2 = double.tryParse(loadCoefficient2) ?? 0.0;
    double activePowerBus = utilizationCoef2 * 752.0;
    double reactivePowerBus = utilizationCoef2 * 657.0;
    double apparentPowerBus =
        sqrt(pow(activePowerBus, 2) + pow(reactivePowerBus, 2));
    double busCurrent = activePowerBus / 0.38;

    totalActivePowerDept1 = activePowerBus.toString();
    totalReactivePowerDept1 = reactivePowerBus.toString();
    totalApparentPowerDept1 = apparentPowerBus.toString();
    totalCurrentDept1 = busCurrent.toString();

    setState(() {});
  }
}

class Equipment {
  String name;
  String efficiency;
  String powerFactor;
  String voltage;
  String quantity;
  String nominalPower;
  String usageCoefficient;
  String reactivePowerFactor;
  String totalNominalPower;
  String current;

  Equipment([
    this.name = "",
    this.efficiency = "",
    this.powerFactor = "",
    this.voltage = "",
    this.quantity = "",
    this.nominalPower = "",
    this.usageCoefficient = "",
    this.reactivePowerFactor = "",
    this.totalNominalPower = "",
    this.current = "",
  ]);

  Equipment copyWith({
    String? name,
    String? efficiency,
    String? powerFactor,
    String? voltage,
    String? quantity,
    String? nominalPower,
    String? usageCoefficient,
    String? reactivePowerFactor,
    String? totalNominalPower,
    String? current,
  }) {
    return Equipment(
      name ?? this.name,
      efficiency ?? this.efficiency,
      powerFactor ?? this.powerFactor,
      voltage ?? this.voltage,
      quantity ?? this.quantity,
      nominalPower ?? this.nominalPower,
      usageCoefficient ?? this.usageCoefficient,
      reactivePowerFactor ?? this.reactivePowerFactor,
      totalNominalPower ?? this.totalNominalPower,
      current ?? this.current,
    );
  }
}

class EquipmentInputsShape extends StatelessWidget {
  final Equipment equipment;
  final Function(Equipment) onUpdate;

  const EquipmentInputsShape({
    super.key,
    required this.equipment,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      {
        'label': 'Найменування ЕП',
        'value': equipment.name,
        'onChange': (value) => onUpdate(equipment.copyWith(name: value))
      },
      {
        'label': 'Номінальне значення ККД (ηн)',
        'value': equipment.efficiency,
        'onChange': (value) => onUpdate(equipment.copyWith(efficiency: value))
      },
      {
        'label': 'Коефіцієнт потужності навантаження (cos φ)',
        'value': equipment.powerFactor,
        'onChange': (value) => onUpdate(equipment.copyWith(powerFactor: value))
      },
      {
        'label': 'Напруга навантаження (Uн, кВ)',
        'value': equipment.voltage,
        'onChange': (value) => onUpdate(equipment.copyWith(voltage: value))
      },
      {
        'label': 'Кількість ЕП (n, шт)',
        'value': equipment.quantity,
        'onChange': (value) => onUpdate(equipment.copyWith(quantity: value))
      },
      {
        'label': 'Номінальна потужність ЕП (Рн, кВт)',
        'value': equipment.nominalPower,
        'onChange': (value) => onUpdate(equipment.copyWith(nominalPower: value))
      },
      {
        'label': 'Коефіцієнт використання (КВ)',
        'value': equipment.usageCoefficient,
        'onChange': (value) =>
            onUpdate(equipment.copyWith(usageCoefficient: value))
      },
      {
        'label': 'Коефіцієнт реактивної потужності (tg φ)',
        'value': equipment.reactivePowerFactor,
        'onChange': (value) =>
            onUpdate(equipment.copyWith(reactivePowerFactor: value))
      },
    ];

    return Column(
      children: fields.map((field) {
        return Column(
          children: [
            TextField(
              controller:
                  TextEditingController(text: field['value'] as String?),
              onChanged: field['onChange'] as void Function(String),
              decoration: InputDecoration(
                labelText: field['label'] as String,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
}
