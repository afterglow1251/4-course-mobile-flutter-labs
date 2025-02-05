import 'package:flutter/material.dart';
import 'calculator1.dart';
import 'calculator2.dart';
import 'calculator3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

final Map<String, Widget> tabData = {
  'Калькулятор 1': const Calculator1(),
  'Калькулятор 2': const Calculator2(),
  'Калькулятор 3': const Calculator3(),
};

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabData.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            tabs: tabData.keys
                .map((tabName) => Tab(text: tabName))
                .toList(),
          ),
        ),
        body: TabBarView(
          children: tabData.values
              .map((screen) => screen)
              .toList(),
        ),
      ),
    );
  }
}