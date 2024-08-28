
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../common/widgets/customShapes/containers/rounded_container.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../../models/address_model.dart';
import '../../../controllers/address_controller.dart';

class MySingleAddress extends StatelessWidget {
  const MySingleAddress({
    super.key,
    required this.onTap,
    required this.address,
  });

  final AddressModel address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final controller = AddressController.instance;
    final dark = MyHelperFunctions.isDarkMode(context);


    return Obx(
      () {
        final selectedAddressId = controller.selectedAddress.value.id;
        final selectedAddress = selectedAddressId == address.id;
        return InkWell(
        onTap: onTap,
        child: MyRoundedContainer(
          width: double.infinity,
          padding: EdgeInsets.all(MySizes.md),
          showBorder: true,
          backgroundColor: selectedAddress
              ? MyColors.primaryColor.withOpacity(0.5)
              : Colors.transparent,
          borderColor: selectedAddress
              ? Colors.transparent
              : dark
                  ? MyColors.darkerGrey
                  : MyColors.grey,
          margin: EdgeInsets.only(bottom: MySizes.spaceBtwItems),
          child: Stack(
            children: [
              Positioned(
                right: 5,
                top: 0,
                child: Icon(
                  selectedAddress ? Iconsax.tick_circle5 : null,
                  color: selectedAddress
                      ? dark
                          ? MyColors.light
                          : MyColors.dark.withOpacity(0.6)
                      : null,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${address.name}', // Assuming 'name' is the field for the name in your AddressModel
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: MySizes.sm / 2,
                  ),
                  Text(
                    '(${address.phoneNumber})', // Assuming 'phoneNumber' is the field for the phone number in your AddressModel
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: MySizes.sm / 2,
                  ),
                  Text(
                    ' ${address.street} ${address.city}', // Assuming 'street' and 'city' are the fields for the street and city in your AddressModel
                    softWrap: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    );
  }
}
