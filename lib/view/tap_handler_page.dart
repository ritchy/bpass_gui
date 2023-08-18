import 'package:flutter/material.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';

class TapHandlerPage extends StatefulWidget {
  TapHandlerPage(
      {super.key, required this.data, required this.titleColumn, required this.titleRow});

  List<List<String>> data;
  final List<String> titleColumn;
  final List<String> titleRow;

  @override
  _TapHandlerPageState createState() => _TapHandlerPageState();
}

class _TapHandlerPageState extends State<TapHandlerPage> {
  int? selectedRow;
  int? selectedColumn;

  Color getContentColor(int i, int j) {
    if (i == selectedRow && j == selectedColumn) {
      return Colors.amber;
    } else if (i == selectedRow || j == selectedColumn) {
      return Colors.amberAccent;
    } else {
      return Colors.transparent;
    }
  }

  void clearState() => setState(() {
        selectedRow = null;
        selectedColumn = null;
      });

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Tap handler example: highlight selected cell with row & column',
              maxLines: 2,
            ),
            backgroundColor: Colors.amber,
          ),
          body: StickyHeadersTable(
            columnsLength: widget.titleColumn.length,
            rowsLength: widget.titleRow.length,
            columnsTitleBuilder: (i) => TextButton(
              onPressed: clearState,
              child: Text(widget.titleColumn[i]),
            ),
            rowsTitleBuilder: (i) => TextButton(
              onPressed: clearState,
              child: Text(widget.titleRow[i]),
            ),
            contentCellBuilder: (i, j) => ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(getContentColor(i, j)),
                  elevation: MaterialStateProperty.all(0),
                  padding: MaterialStateProperty.all(EdgeInsets.zero)),
              onPressed: () => setState(() {
                selectedColumn = j;
                selectedRow = i;
              }),
              child: Text(
                widget.data[i][j],
                style: const TextStyle(color: Colors.black),
              ),
            ),
            legendCell: TextButton(
              onPressed: clearState,
              child: const Text('Sticky Legend'),
            ),
          ),
        ),
      );
}
