import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/utils/constants/colors.dart';

import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../screens/personalization/controllers/address_controller.dart';

class MyBillingAddressSection extends StatelessWidget {
  const MyBillingAddressSection({Key? key});

  @override
  Widget build(BuildContext context) {
    final addressController = AddressController.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Shipping Address',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            TextButton(
              onPressed: () => addressController.selectNewAddressPopup(context),
              child: Text(
                'Change',
                style: TextStyle(
                  color: MyColors.primaryColor, // Custom color for the button
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        Obx(
              () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                addressController.selectedAddress.value.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: MySizes.spaceBtwItems / 2),
              Row(
                children: [
                  const Icon(Icons.phone, color: MyColors.primaryColor, size: 16),
                  const SizedBox(width: MySizes.spaceBtwItems),
                  Text(
                    addressController.selectedAddress.value.phoneNumber,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: MySizes.spaceBtwItems / 2),
              Row(
                children: [
                  const Icon(Icons.location_history, color: MyColors.primaryColor, size: 16),
                  const SizedBox(width: MySizes.spaceBtwItems),
                  Text(
                    '${addressController.selectedAddress.value.street}, ${addressController.selectedAddress.value.city}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
