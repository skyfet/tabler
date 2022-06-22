import 'package:flutter/material.dart';
import 'package:tabler/tabler.dart';

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

  @override
  void initState() {
    _columns = [
      TablerColumn(
        header: const CustomHeader(text: 'First'),
        flex: 1,
      ),
      TablerColumn(
        header: const CustomHeader(text: 'Second'),
        flex: 3,
      ),
      TablerColumn(
        header: const CustomHeader(text: 'Third'),
        width: 500,
      ),
      TablerColumn(header: const CustomHeader(text: 'Fourth')),
    ];
    _controller = TablerController(
      limit: 3,
      onUpdate: _onTableUpdate,
      initialList: ['Data 1', 'Data 2', 'Data 3'],
      totalCount: 5,
    );

    super.initState();
  }

  Future<void> _onTableUpdate(int limit, int offset) async {
    _controller.appendItems(['Data 4', 'Data 5']);
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
            mainAxisAlignment: MainAxisAlignment.end,
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
            ].map((w) => Align(child: w)).toList(),
          ),
          loadingWidget: const SizedBox(
            height: 100 - 32,
            width: 100 - 32,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
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
