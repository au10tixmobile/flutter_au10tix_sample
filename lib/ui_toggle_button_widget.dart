import 'package:flutter/material.dart';

class UIToggleButtonsWidget extends StatefulWidget {
  final Function(int, bool) onToggle;

  const UIToggleButtonsWidget({Key? key, required this.onToggle})
      : super(key: key);

  @override
  _UIToggleButtonsWidgetState createState() => _UIToggleButtonsWidgetState();
}

class _UIToggleButtonsWidgetState extends State<UIToggleButtonsWidget> {
  static const List<List<String>> buttonTextsPair = [
    ['SCloseBtn', 'HCloseBtn'],
    ['SPrimaryBtn', 'HPrimaryBtn'],
    ['SUploadBtn', 'HUploadBtn'],
    ['SIntro', 'HIntro']
  ];
  late final selected = List.generate(buttonTextsPair.length, (index) => true);

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: List.generate(
        buttonTextsPair.length,
        (index) {
          final buttonText = selected[index]
              ? buttonTextsPair[index][1]
              : buttonTextsPair[index][0];
          return Padding(
            padding: const EdgeInsets.all(8.0), // Adjust padding as needed
            child: Text(buttonText),
          );
        },
      ),
      isSelected: selected,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      onPressed: (index) {
        setState(() {
          selected[index] = !selected[index];
          widget.onToggle(index, selected[index]); // Call the callback
        });
      },
    );
  }
}
