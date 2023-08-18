import 'package:flutter/material.dart';

class EntryList extends StatelessWidget {
  final List<String> items;

  const EntryList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    //const title = 'Long List';

    return ListView.builder(
        itemCount: items.length,
        prototypeItem: ListTile(
          title: Text(items.first),
        ),
        itemBuilder: (context, index) {
          //return ListTile(
          //  title: Text(items[index]),
          //);
          return TextField(
              decoration: InputDecoration(
                  border: const OutlineInputBorder(), labelText: items[index]));
        });
  }
}
