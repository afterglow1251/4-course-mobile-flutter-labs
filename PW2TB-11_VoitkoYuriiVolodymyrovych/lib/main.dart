import 'package:flutter/material.dart';
import 'calculator1.dart';

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
  'Калькулятор': const Calculator1(),
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