
import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../customShapes/containers/rounded_container.dart';

class MyCouponCode extends StatelessWidget {
  const MyCouponCode({
    super.key,
  });



  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);

    return MyRoundedContainer(
      showBorder: true,
      backgroundColor: dark ? MyColors.dark : MyColors.white,
      padding: const EdgeInsets.only(
        top: MySizes.sm,
        bottom: MySizes.sm,
        right: MySizes.sm,
        left: MySizes.md,
      ),
      child: Row(
        children: [
          /// promo text field
          Flexible(
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Have a promo code? Enter here',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),

          /// apply button
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.2),
                foregroundColor: dark ? MyColors.white.withOpacity(0.5) : MyColors.dark.withOpacity(0.5),
                side: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}