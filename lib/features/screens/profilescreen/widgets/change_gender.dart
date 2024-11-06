import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/sizes.dart';
import 'change_gender_controller.dart';

class ChangeGenderDialog extends StatelessWidget {
  const ChangeGenderDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateGenderController());

    // Ensure the gender value is initialized properly
    if (controller.gender.value.isEmpty) {
      controller.gender.value = 'Male'; // Default to 'Male' or any other default value
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(MySizes.defaultspace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select your gender.',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: MySizes.spaceBtwSections),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.gender.value.isNotEmpty ? controller.gender.value : null,
                  onChanged: (value) => controller.gender.value = value ?? '',
                  items: ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
                      .toList(),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                  ),
                )),
                const SizedBox(height: MySizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.updateGender(context); // Pass context here
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
