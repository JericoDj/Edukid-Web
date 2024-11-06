import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/update_birthday_controller.dart';

import '../../../../utils/constants/sizes.dart';

class ChangeBirthdayDialog extends StatelessWidget {
  const ChangeBirthdayDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateBirthdayController());
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
                'Update your birthday.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: MySizes.spaceBtwSections),

              // Display birthday and trigger date picker
              Obx(() => TextFormField(
                controller: TextEditingController(text: controller.birthday.value),
                readOnly: true,
                onTap: () => controller.selectBirthday(context),
                decoration: const InputDecoration(
                  labelText: 'Birthday',
                  prefixIcon: Icon(Iconsax.calendar),
                ),
              )),
              const SizedBox(height: MySizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.updateBirthday(context); // Pass context here
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
