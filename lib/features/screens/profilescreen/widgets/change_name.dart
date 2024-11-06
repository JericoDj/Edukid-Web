import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/update_name_controller.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/validators/validation.dart';

class ChangeNameDialog extends StatelessWidget {
  const ChangeNameDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateNameController());
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        // Set a maximum width for the dialog
        child: Padding(
          padding: const EdgeInsets.all(MySizes.defaultspace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // Ensure dialog takes minimal height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Use real name for easy verification. This name will appear on several pages.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: MySizes.spaceBtwSections),
              Form(
                key: controller.updateUserNameFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.firstName,
                      validator: (value) =>
                          MyValidator.validateEmptyText('First name', value),
                      decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Iconsax.user)),
                    ),
                    const SizedBox(height: MySizes.spaceBtwInputItems),
                    TextFormField(
                      controller: controller.lastName,
                      validator: (value) =>
                          MyValidator.validateEmptyText('Last Name', value),
                      decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Iconsax.user)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MySizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.updateUserName(context); // Perform update
                    // Pass the updated name back to the previous screen

                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
