import 'package:flutter/material.dart';

class PersonalDataDialog extends StatelessWidget {
  final TextEditingController firstNameController =
      TextEditingController(text: "John");
  final TextEditingController lastNameController =
      TextEditingController(text: "Smith");
  final TextEditingController addressController =
      TextEditingController(text: "123 Abbey Rd., London GBR");
  final Function(String, String, String, BuildContext)
      onContinue; // Added onContinue parameter
  PersonalDataDialog({Key? key, required this.onContinue}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Personal Data for Compare'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: firstNameController,
            decoration: const InputDecoration(hintText: 'First Name'),
          ),
          TextField(
            controller: lastNameController,
            decoration: const InputDecoration(hintText: 'Last Name'),
          ),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(hintText: 'Address'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Handle clear button press
            firstNameController.clear();
            lastNameController.clear();
            addressController.clear();
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () {
            final firstName = firstNameController.text;
            final lastName = lastNameController.text;
            final address = addressController.text;
            onContinue(firstName, lastName, address, context);
            Navigator.of(context).pop();
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
