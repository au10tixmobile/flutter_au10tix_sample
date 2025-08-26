import 'package:flutter/material.dart';

class UIToggleButtonsWidget extends StatefulWidget {
  final Function(int, bool) onToggle;

  const UIToggleButtonsWidget({super.key, required this.onToggle});

  @override
  UIToggleButtonsWidgetState createState() => UIToggleButtonsWidgetState();
}

class UIToggleButtonsWidgetState extends State<UIToggleButtonsWidget> {
  static const List<List<String>> buttonTextsPair = [
    ['Show Close Button', 'Hide Close Button'],
    ['Show Primary Button', 'Hide Primary Button'],
    ['Show Upload Button', 'Hide Upload Button'],
    ['Show Intro', 'Hide Intro']
  ];
  late final selected = List.generate(buttonTextsPair.length, (index) => true);

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: selected,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      onPressed: (index) {
        setState(() {
          selected[index] = !selected[index];
          widget.onToggle(index, selected[index]); // Call the callback
        });
      },
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
    );
  }
}
