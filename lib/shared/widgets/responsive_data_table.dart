import 'package:flutter/material.dart';

class ResponsiveDataTable extends StatelessWidget {
  const ResponsiveDataTable({
    required this.columns,
    required this.rows,
    super.key,
  });
  final List<DataColumn> columns;
  final List<DataRow> rows;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) => Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(columns: columns, rows: rows),
        ),
      ),
    ),
  );
}
