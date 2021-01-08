import 'package:broker/models/most_gainers.dart';
import 'package:broker/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data_notifier.dart';

class GainTable extends StatelessWidget {
  GainTable(this.sourceData);

  final List<MostGainersModel> sourceData;

  void _sort<T>(
    Comparable<T> Function(MostGainersModel inv) getField,
    int colIndex,
    bool asc,
    _DataSource _src,
    DataNotifier _provider,
  ) {
    _src.sort<T>(getField, asc);
    _provider.sortAscending = asc;
    _provider.sortColumnIndex = colIndex;
  }

  Widget build(BuildContext context) {
    final _provider = context.watch<DataNotifier>();

    return Card(
      elevation: 3.0,
      child: SizedBox(
        width: double.infinity,
        child: PaginatedDataTable(
          header: Text("Most Gainers"),
          columnSpacing: 24.0,
          dataRowHeight: 30.0,
          rowsPerPage: _provider.rowsPerPage,
          onRowsPerPageChanged: (index) => _provider.rowsPerPage = index,
          // availableRowsPerPage: [5, 10, 15, 20],
          sortAscending: _provider.sortAscending,
          sortColumnIndex: _provider.sortColumnIndex,

          showCheckboxColumn: false,
          columns: [
            DataColumn(
              label: Text('Ticker'),
              onSort: (columnIndex, ascending) {
                _sort<String>((inv) => inv.tickers, columnIndex, ascending,
                    _DataSource(context: context, rows: sourceData), _provider);
              },
            ),
            DataColumn(
              label: Text('Price'),
              onSort: (columnIndex, ascending) {
                _sort<String>((inv) => inv.price, columnIndex, ascending,
                    _DataSource(context: context, rows: sourceData), _provider);
              },
            ),
            DataColumn(
              label: Text('Changes'),
              onSort: (columnIndex, ascending) {
                _sort<String>(
                    (inv) => inv.changes.toString(),
                    columnIndex,
                    ascending,
                    _DataSource(context: context, rows: sourceData),
                    _provider);
              },
            ),
            DataColumn(
              label: Text('Change %'),
              onSort: (columnIndex, ascending) {
                _sort<String>(
                    (inv) => inv.changesPercentage,
                    columnIndex,
                    ascending,
                    _DataSource(context: context, rows: sourceData),
                    _provider);
              },
            ),
            DataColumn(
              label: Text('Company Name'),
              onSort: (columnIndex, ascending) {
                _sort<String>((inv) => inv.companyName, columnIndex, ascending,
                    _DataSource(context: context, rows: sourceData), _provider);
              },
            ),
          ],
          source: _DataSource(context: context, rows: sourceData),
        ),
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  _DataSource({this.context, this.rows});

  final BuildContext context;
  final List<MostGainersModel> rows;

  int _selectedCount = 0;
  int _lastIndex = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= rows.length) return null;
    final row = rows[index];

    Color _color;
    Icon _icon;

    if (row.changes > 0) {
      _color = Colors.green;
      _icon = Icon(
        Icons.arrow_circle_up_outlined,
        color: Colors.green,
      );
    } else {
      _color = Colors.red;
      _icon = Icon(
        Icons.arrow_circle_down_outlined,
        color: Colors.red,
      );
    }

    return DataRow.byIndex(
      index: index,
      selected: row.selected,
      onSelectChanged: (value) {
        rows[_lastIndex].selected = false;
        _lastIndex = index;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Chart(
                    title: row.companyName,
                    symbol: row.tickers,
                  )),
        );
        if (row.selected != value) {
          row.selected = value;
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text(row.tickers ?? '')),
        DataCell(Text(row.price.toString() ?? '')),
        DataCell(Text(row.changes.toString() ?? '')),
        DataCell(Row(
          children: [
            _icon,
            _textColor(row.changesPercentage, _color),
          ],
        )),
        DataCell(Text(row.companyName)),

        // DataCell(Text(row.alink ?? '')),
      ],
    );
  }

  Widget _textColor(String data, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          data,
        ),
      ),
    );
  }

  void sort<T>(Comparable<T> Function(MostGainersModel d) getField, bool asc) {
    rows.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      return asc
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    notifyListeners();
  }

  @override
  int get rowCount => rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
