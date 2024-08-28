
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utitility.dart';
import '../../../../utils/helpers/helper_functions.dart';

class MySearchContainer extends StatelessWidget {
  const MySearchContainer({
    super.key,
    required this.text,
    this.icon = Iconsax.search_normal,
    this.showBackround = true,
    this.showBorder = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: MySizes.defaultspace),
  });

  final String text;
  final IconData? icon;
  final bool showBackround, showBorder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
            width: MyDeviceUtils.getScreenWidth(context),
            padding: const EdgeInsets.all(MySizes.md),
            decoration: BoxDecoration(
              color: showBackround
                  ? dark
                      ? MyColors.dark
                      : MyColors.light
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(MySizes.cardRadiusLg),
              border: showBorder ? Border.all(color: MyColors.primaryColor) : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: MyColors.darkerGrey),
                const SizedBox(
                  width: MySizes.spaceBtwItems,
                ),
                Text(text, style: Theme.of(context).textTheme.bodySmall),
              ],
            )
        ),
      ),
    );
  }
}
