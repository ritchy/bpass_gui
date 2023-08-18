import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:super_tag_editor/widgets/rich_text_widget.dart';

class AccountTagEditor extends StatefulWidget {
  const AccountTagEditor(this.tags, {Key? key, this.title}) : super(key: key);

  final String? title;
  final List<String> tags;

  @override
  _AccountTagEditor createState() => _AccountTagEditor();
}

class _AccountTagEditor extends State<AccountTagEditor> {
  static const mockResults = [
    'dat@gmail.com',
    'dab246@gmail.com',
    'kaka@gmail.com',
    'datvu@gmail.com'
  ];

  List<String> _values = [];
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();
  bool focusTagEnabled = false;

  _onDelete(index) {
    setState(() {
      _values.removeAt(index);
    });
  }

  /// This is just an example for using `TextEditingController` to manipulate
  /// the the `TextField` just like a normal `TextField`.
  _onPressedModifyTextField() {
    const text = 'Test';
    _textEditingController.text = text;
    _textEditingController.value = _textEditingController.value.copyWith(
      text: text,
      selection: const TextSelection(
        baseOffset: text.length,
        extentOffset: text.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _values = widget.tags;
    return TagEditor<String>(
      length: _values.length,
      controller: _textEditingController,
      focusNode: _focusNode,
      delimiters: const [',', ' '],
      hasAddButton: true,
      resetTextOnSubmitted: true,
      textAlign: TextAlign.left,
      // This is set to grey just to illustrate the `textStyle` prop
      //textStyle: const TextStyle(color: Colors.blue),
      onSubmitted: (outstandingValue) {
        setState(() {
          _values.add(outstandingValue);
        });
      },
      inputDecoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Enter Tag ...',
      ),
      onTagChanged: (newValue) {
        setState(() {
          _values.add(newValue);
        });
      },
      tagBuilder: (context, index) => Container(
        padding: const EdgeInsets.fromLTRB(0, 5, 2, 0),
        color: focusTagEnabled && index == _values.length - 1
            ? Colors.redAccent
            : Colors.transparent,
        child: _Chip(
          index: index,
          label: _values[index],
          onDeleted: _onDelete,
        ),
      ),
      // InputFormatters example, this disallow \ and /
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[/\\]'))],
      useDefaultHighlight: false,
      suggestionBuilder:
          (context, state, data, index, length, highlight, suggestionValid) {
        var borderRadius = const BorderRadius.all(Radius.circular(20));
        if (index == 0) {
          borderRadius = const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          );
        } else if (index == length - 1) {
          borderRadius = const BorderRadius.only(
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          );
        }
        return InkWell(
          onTap: () {
            setState(() {
              _values.add(data);
            });
            state.resetTextField();
            state.closeSuggestionBox();
          },
          child: Container(
              decoration: highlight
                  ? BoxDecoration(
                      color: Theme.of(context).focusColor,
                      borderRadius: borderRadius)
                  : null,
              padding: const EdgeInsets.all(16),
              child: RichTextWidget(
                wordSearched: suggestionValid ?? '',
                textOrigin: data,
              )),
        );
      },
      onFocusTagAction: (focused) {
        setState(() {
          focusTagEnabled = focused;
        });
      },
      onDeleteTagAction: () {
        if (_values.isNotEmpty) {
          setState(() {
            _values.removeLast();
          });
        }
      },
      onSelectOptionAction: (item) {
        setState(() {
          _values.add(item);
        });
      },
      suggestionsBoxElevation: 10,
      findSuggestions: (String query) {
        if (query.isNotEmpty) {
          var lowercaseQuery = query.toLowerCase();
          return mockResults.where((profile) {
            return profile.toLowerCase().contains(query.toLowerCase()) ||
                profile.toLowerCase().contains(query.toLowerCase());
          }).toList(growable: false)
            ..sort((a, b) => a
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.toLowerCase().indexOf(lowercaseQuery)));
        }
        return [];
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onDeleted,
    required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white,
      labelPadding: const EdgeInsets.only(left: 8.0),
      label: Text(label),
      deleteIcon: const Icon(
        Icons.close,
        size: 18,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}
