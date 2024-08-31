import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/update_phone_number_controller.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/validators/validation.dart';

class ChangePhoneNumberDialog extends StatelessWidget {
  const ChangePhoneNumberDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdatePhoneNumberController());
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(MySizes.defaultspace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update your phone number for account security.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: MySizes.spaceBtwSections),
              Form(
                key: controller.updatePhoneNumberFormKey,
                child: TextFormField(
                  controller: controller.phoneNumber,
                  validator: (value) => MyValidator.validatePhoneNumber(value),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Iconsax.call),
                  ),
                ),
              ),
              const SizedBox(height: MySizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.updatePhoneNumber();
                    Get.back(result: {'phoneNumber': controller.phoneNumber.text});
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
