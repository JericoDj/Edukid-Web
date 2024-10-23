import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangeNameDialog extends StatelessWidget {
  const ChangeNameDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save the name and close dialog
                Get.back(result: {
                  'firstName': firstNameController.text,
                  'lastName': lastNameController.text
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
