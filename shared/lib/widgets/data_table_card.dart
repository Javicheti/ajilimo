import 'package:flutter/material.dart';

import '../design/semantic_colors.dart';
import '../design/tokens.dart';
import 'app_card.dart';

/// Columna de una tabla con alineación opcional a la derecha.
class TableColumn {
  const TableColumn(this.label, {this.numeric = false});
  final String label;
  final bool numeric;
}

/// Tabla premium dentro de una tarjeta, con encabezado y acciones.
class DataTableCard extends StatelessWidget {
  const DataTableCard({
    super.key,
    this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    required this.columns,
    required this.rows,
  });

  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final List<TableColumn> columns;
  final List<List<Widget>> rows;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.md, Spacing.sm),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title!, style: Theme.of(context).textTheme.titleMedium),
                        if (subtitle != null)
                          Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
          Divider(height: 1, color: c.border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll<Color>(c.surfaceAlt),
              headingTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              dataTextStyle: Theme.of(context).textTheme.bodyMedium,
              dividerThickness: 0,
              columns: <DataColumn>[
                for (final TableColumn column in columns)
                  DataColumn(label: Text(column.label), numeric: column.numeric),
              ],
              rows: <DataRow>[
                for (final List<Widget> row in rows)
                  DataRow(cells: <DataCell>[for (final Widget cell in row) DataCell(cell)]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
