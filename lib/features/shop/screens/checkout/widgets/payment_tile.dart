import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/customShapes/containers/rounded_container.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controller/product/checkout_controller.dart';
import '../../../models/payment_method_model.dart';
class MyPaymentTile extends StatelessWidget {
  const MyPaymentTile({Key? key, required this.paymentMethod, required this.onTap}) : super(key: key);

  final PaymentMethodModel paymentMethod;
  final VoidCallback onTap; // Add a callback for handling tap events

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      onTap: onTap, // Use the onTap callback
      leading: MyRoundedContainer(
        width: 60,
        height: 40,
        backgroundColor: MyHelperFunctions.isDarkMode(context)
            ? MyColors.light
            : MyColors.white,
        padding: const EdgeInsets.all(MySizes.sm),
        child: Image(image: AssetImage(paymentMethod.image), fit: BoxFit.contain),
      ),
      title: Text(paymentMethod.name),
      trailing: const Icon(Iconsax.arrow_right_34),
    );
  }
}
