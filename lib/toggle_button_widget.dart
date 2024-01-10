import 'package:flutter/material.dart';

class ToggleButtonsWidget extends StatefulWidget {
  final Function(int, bool) onToggle;

  const ToggleButtonsWidget({Key? key, required this.onToggle})
      : super(key: key);

  @override
  _ToggleButtonsWidgetState createState() => _ToggleButtonsWidgetState();
}

class _ToggleButtonsWidgetState extends State<ToggleButtonsWidget> {
  static const List<Widget> options = <Widget>[
    Text('CloseBtn'),
    Text('PrimaryBtn'),
    Text('UploadBtn'),
    Text('Intro')
  ];

  late final selected = List.generate(options.length, (index) => true);

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: options
          .map((option) => Padding(
                padding: const EdgeInsets.all(8.0), // Adjust padding as needed
                child: option,
              ))
          .toList(),
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
