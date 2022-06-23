import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tabler/flutter_tabler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TablerController<String> _controller;
  late final List<TablerColumn> _columns;
  int index = 1;

  @override
  void initState() {
    _columns = [
      TablerColumn(
        header: const CustomHeader(text: '#'),
        width: 48,
      ),
      TablerColumn(
        header: const CustomHeader(text: 'Earth 01'),
        flex: 3,
      ),
      TablerColumn(
        header: const CustomHeader(text: 'Earth 02'),
        width: 500,
      ),
      TablerColumn(header: const CustomHeader(text: 'Earth 03')),
    ];
    _controller = TablerController(
      limit: 25,
      onUpdate: _onTableUpdate,
      initialList: List.generate(25, (_) => 'Hero ${index++}'),
      totalCount: 100,
    );

    super.initState();
  }

  Future<void> _onTableUpdate(int limit, int offset) async {
    await Future.delayed(const Duration(seconds: 1));
    _controller
      ..appendItems(List.generate(limit, (_) => 'Hero ${index++}'))
      ..update();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: Tabler<String>(
            controller: _controller,
            columns: _columns,
            rowBuilder: TablerRowBuilder(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              builder: (item, index) => [
                Center(child: Text('${index + 1}')),
                CustomCell(text: item),
                CustomCell(text: item),
                CustomCell(text: item),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller
            ..list = _controller.list.map(
              (line) {
                if (Random.secure().nextInt(100) > 90) {
                  return line.replaceFirst('Hero', 'Evil');
                }
                return line;
              },
            ).toList()
            ..update();
        },
        child: const Icon(Icons.precision_manufacturing),
      ),
    );
  }
}

class CustomCell extends StatelessWidget {
  const CustomCell({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(width: .5),
          left: BorderSide(width: .5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          Chip(
            avatar: const Icon(
              Icons.star,
              color: Colors.yellow,
            ),
            label: Text(
              Random.secure().nextInt(10).toString(),
            ),
          )
        ],
      ),
    );
  }
}

class CustomHeader extends StatelessWidget {
  const CustomHeader({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(width: .5),
          left: BorderSide(width: .5),
          bottom: BorderSide(width: 5),
        ),
        color: Colors.orange,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(text)),
      ),
    );
  }
}
