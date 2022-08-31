import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Tabler<T> extends StatelessWidget {
  const Tabler({
    required this.columns,
    required this.controller,
    required this.rowBuilder,
    this.loadingWidget,
    this.placeholder,
    this.errorBuilder,
    Key? key,
  }) : super(key: key);

  final TablerController<T> controller;
  final List<TablerColumn> columns;

  /// `List<Widget> Function(T item, int index)`
  final TablerRowBuilder<T> rowBuilder;

  final Widget? loadingWidget;
  final Widget? placeholder;
  final Widget Function(Object? error)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: controller,
      child: BlocBuilder<TablerController<T>, List<T>>(
        builder: (context, _) => Column(
          children: [
            Row(
              mainAxisAlignment: rowBuilder.mainAxisAlignment,
              crossAxisAlignment: rowBuilder.crossAxisAlignment,
              mainAxisSize: rowBuilder.mainAxisSize,
              textBaseline: rowBuilder.textBaseline,
              textDirection: rowBuilder.textDirection,
              verticalDirection: rowBuilder.verticalDirection,
              children: columns
                  .map(
                    (column) => _buildCell(column, column.header),
                  )
                  .toList(),
            ),
            Expanded(
              child: controller.list.isEmpty
                  ? Center(
                      child: placeholder ??
                          Text(
                            'No rows',
                            style: Theme.of(context).textTheme.headline4,
                          ),
                    )
                  : ListView.builder(
                      controller: controller.scrollController,
                      itemCount: controller.list.length < controller.totalCount
                          ? controller.list.length + 1
                          : controller.list.length,
                      itemBuilder: (context, index) {
                        final item = controller.itemAt(index);
                        if (item != null) {
                          return _buildItem(item, index);
                        }
                        return FutureBuilder<void>(
                          future: controller.onUpdate(controller.limit, index),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return errorBuilder?.call(snapshot.error) ??
                                  Center(
                                    child: ErrorWidget('${snapshot.error}'),
                                  );
                            }
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: loadingWidget ??
                                    const CircularProgressIndicator(),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(T item, int index) {
    final children = rowBuilder.builder(item, index);

    assert(
      children.length == columns.length,
      'The length of the list returned by [TablerRow.builder] '
      'must match the length of the [Tabler.columns] list!',
    );

    final sizedChildren = columns
        .asMap()
        .map(
          (index, column) {
            final child = children.elementAt(index);
            return MapEntry(
              index,
              _buildCell(column, child),
            );
          },
        )
        .values
        .toList();

    return Container(
      decoration:
          rowBuilder.decorationBuilder?.call(item) ?? rowBuilder.decoration,
      height: rowBuilder.height,
      child: InkWell(
        onTap: rowBuilder.onTap != null
            ? () => rowBuilder.onTap!(item, index)
            : null,
        child: Row(
          mainAxisAlignment: rowBuilder.mainAxisAlignment,
          crossAxisAlignment: rowBuilder.crossAxisAlignment,
          mainAxisSize: rowBuilder.mainAxisSize,
          textBaseline: rowBuilder.textBaseline,
          textDirection: rowBuilder.textDirection,
          verticalDirection: rowBuilder.verticalDirection,
          children: sizedChildren,
        ),
      ),
    );
  }

  Widget _buildCell(TablerColumn column, Widget child) => column.hasWidth
      ? SizedBox(width: column.width, child: child)
      : Expanded(flex: column.flex, child: child);
}

class TablerRowBuilder<T> {
  TablerRowBuilder({
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    //* InkWell
    this.onTap,
    //* Container
    this.decoration,
    this.decorationBuilder,
    this.height,
    required this.builder,
  }) : assert(
          decoration == null || decorationBuilder == null,
          'You cannot specify decoration and decorationBuilder at the same time.',
        );

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final void Function(T item, int index)? onTap;
  final Decoration? decoration;
  final Decoration Function(T item)? decorationBuilder;
  final double? height;
  final List<Widget> Function(T item, int index) builder;
}

class TablerController<T> extends Cubit<List<T>> {
  TablerController({
    required this.onUpdate,
    int? limit,
    List<T>? initialList,
    int? totalCount,
    ScrollController? scrollController,
  })  : list = initialList ?? [],
        totalCount = totalCount ?? 0,
        scrollController = scrollController ?? ScrollController(),
        limit = limit ?? 30,
        super(initialList ?? []);

  /// `FutureOr<void> Function(int limit, int offset) onUpdate`
  final Future<void> Function(int limit, int offset) onUpdate;

  final ScrollController scrollController;

  int totalCount;
  List<T> list;
  int limit;

  void appendItems(Iterable<T> items) => list = [...list, ...items];

  void update() => emit(list);

  T? itemAt(int index) => list.length <= index ? null : list.elementAt(index);

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}

class TablerColumn {
  TablerColumn({
    this.width,
    int? flex,
    this.onSort,
    TablerSorting? defaultSorting,
    required this.header,
  })  : assert(
          !(flex != null && width != null),
          'Specify either width or flex. You cannot specify both parameters at the same time.',
        ),
        flex = flex ?? 1,
        sorting = defaultSorting ?? TablerSorting.none;

  final Widget header;
  final int flex;
  final double? width;
  final TablerSorting sorting;

  /// `void Function(int columnIndex, TablerSorting currentSorting)`
  final TablerSorter? onSort;

  bool get hasWidth => width != null;
}

enum TablerSorting { none, asc, desc }

typedef TablerSorter = void Function(
  int columnIndex,
  TablerSorting currentSorting,
);
