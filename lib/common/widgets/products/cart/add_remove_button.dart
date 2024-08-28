
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../icons/my_circular_icon.dart';

class MyProductQuantityWithAddRemoveButton extends StatelessWidget {
  const MyProductQuantityWithAddRemoveButton({
    super.key, required this.quantity, this.add, this.remove,
  });

  final int quantity;
  final VoidCallback? add, remove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 70),

        /// Add Remove Buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyCircularIcon(
              icon: Iconsax.minus,
              width: 32,
              height: 32,
              size: MySizes.md,
              color: MyHelperFunctions.isDarkMode(context)
                  ? MyColors.white
                  : MyColors.black,
              backroundColor: MyHelperFunctions.isDarkMode(context)
                  ? MyColors.darkerGrey
                  : MyColors.light,
              onPressed: remove,
            ), // TCircularIcon
            const SizedBox(width: MySizes.spaceBtwItems),
            Text(quantity.toString(), style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: MySizes.spaceBtwItems),
             MyCircularIcon(
              icon: Iconsax.add,
              width: 32,
              height: 32,
              size: MySizes.md,
              color: MyColors.white,
              backroundColor: MyColors.primaryColor,
              onPressed: add,
            )
          ],
        )
        // Add other widgets or UI components for each cart item
      ],
    );
  }
}