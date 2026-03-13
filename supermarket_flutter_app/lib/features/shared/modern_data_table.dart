import 'package:flutter/material.dart';

class ModernDataTable extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool showCheckboxColumn;
  final int rowsPerPage;

  const ModernDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showCheckboxColumn = false,
    this.rowsPerPage = 10,
  });

  @override
  State<ModernDataTable> createState() => _ModernDataTableState();
}

class _ModernDataTableState extends State<ModernDataTable> {
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  int _rowsPerPage = 10;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.rowsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalRows = widget.rows.length;
    final totalPages = (totalRows / _rowsPerPage).ceil();
    final start = _page * _rowsPerPage;
    final end = ((start + _rowsPerPage) > totalRows) ? totalRows : (start + _rowsPerPage);
    final pageRows = widget.rows.sublist(start, end);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DataTable(
              columns: widget.columns.asMap().entries.map((entry) {
                final i = entry.key;
                final col = entry.value;
                return DataColumn(
                  label: col.label,
                  tooltip: col.tooltip,
                  numeric: col.numeric,
                  onSort: (col.onSort != null)
                      ? col.onSort
                      : (i == _sortColumnIndex)
                          ? (columnIndex, ascending) {
                              setState(() {
                                _sortColumnIndex = columnIndex;
                                _sortAscending = ascending;
                              });
                            }
                          : null,
                );
              }).toList(),
              rows: pageRows,
              showCheckboxColumn: widget.showCheckboxColumn,
              dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.selected)) {
                  return theme.colorScheme.primary.withOpacity(0.08);
                }
                return null;
              }),
              headingRowColor: MaterialStateProperty.all(theme.colorScheme.primary.withOpacity(0.08)),
              dividerThickness: 0.8,
              dataRowHeight: 56,
              headingRowHeight: 56,
              horizontalMargin: 24,
              columnSpacing: 32,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rows ${start + 1} - $end of $totalRows', style: theme.textTheme.bodySmall),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous Page',
                      onPressed: _page > 0
                          ? () => setState(() => _page--)
                          : null,
                    ),
                    Text('${_page + 1} / $totalPages', style: theme.textTheme.bodySmall),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next Page',
                      onPressed: _page < totalPages - 1
                          ? () => setState(() => _page++)
                          : null,
                    ),
                  ],
                ),
                DropdownButton<int>(
                  value: _rowsPerPage,
                  items: (() {
                    final defaultOptions = [5, 10, 20, 50];
                    final options = List<int>.from(defaultOptions);
                    if (!options.contains(_rowsPerPage)) {
                      // Ensure the current rowsPerPage is selectable to avoid
                      // DropdownButton assertion when a caller provides a
                      // custom value (e.g., search result count).
                      options.insert(0, _rowsPerPage);
                    }
                    return options.map((v) => DropdownMenuItem(value: v, child: Text('$v / page'))).toList();
                  })(),
                  onChanged: (v) {
                    if (v != null) setState(() { _rowsPerPage = v; _page = 0; });
                  },
                  underline: const SizedBox(),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
