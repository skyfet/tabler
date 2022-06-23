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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
        header: const CustomHeader(text: 'Earth 01'),
        flex: 1,
      ),
      TablerColumn(
        header: const CustomHeader(text: 'Earth 02'),
        flex: 3,
      ),
      TablerColumn(
        header: const CustomHeader(text: 'Earth 03'),
        width: 500,
      ),
      TablerColumn(header: const CustomHeader(text: 'Earth 04')),
    ];
    _controller = TablerController(
      limit: 1,
      onUpdate: _onTableUpdate,
      initialList: List.generate(2, (_) => 'Hero ${index++}'),
      totalCount: 5,
    );

    super.initState();
  }

  Future<void> _onTableUpdate(int limit, int offset) async {
    await Future.delayed(const Duration(seconds: 2));
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
      body: Center(
        child: Tabler<String>(
          controller: _controller,
          columns: _columns,
          rowBuilder: TablerRowBuilder(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.07),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFD6D6D6)),
                right: BorderSide(color: Color(0xFFD6D6D6)),
                left: BorderSide(color: Color(0xFFD6D6D6)),
              ),
            ),
            builder: (item, _) => [
              CustomCell(text: item),
              CustomCell(text: item),
              CustomCell(text: item),
              CustomCell(text: item),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller
            ..totalCount = 5
            ..list = ['Evil 1', 'Evil 2', 'Evil 3', 'Evil 4', 'Evil 5']
            ..update();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class CustomCell extends StatelessWidget {
  const CustomCell({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(text),
    );
  }
}

class CustomHeader extends StatelessWidget {
  const CustomHeader({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(text)),
      ),
    );
  }
}
