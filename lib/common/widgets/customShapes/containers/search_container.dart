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
<<<<<<< HEAD
  final Function(String)? onTap; // Function that takes a String input
=======
  final VoidCallback? onTap;
>>>>>>> 8d9d7c4708cd91881283eb101aa12a4d80b10623
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
<<<<<<< HEAD
    final TextEditingController searchController = TextEditingController(); // Controller for the TextField

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(searchController.text); // Call the function with the current input
        }
      },
      child: Padding(
        // Adjust this padding value to move the search bar down
        padding: const EdgeInsets.only(top: 30, bottom: 30),
=======
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        // Adjust this padding value to move the search bar down
        padding: const EdgeInsets.only(top: 25, bottom: 25),
>>>>>>> 8d9d7c4708cd91881283eb101aa12a4d80b10623
        child: Container(
          height: 45,
          width: MyDeviceUtils.getScreenWidth(context),
          padding: const EdgeInsets.all(MySizes.xs),
          decoration: BoxDecoration(
            color: showBackround
                ? dark
                ? MyColors.dark
                : MyColors.light
                : Colors.transparent,
            borderRadius: BorderRadius.circular(MySizes.cardRadiusMd),
            border: showBorder ? Border.all(color: MyColors.primaryColor) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: MyColors.darkerGrey),
<<<<<<< HEAD
              const SizedBox(width: MySizes.spaceBtwItems),
              Expanded(
                child: TextField(
                  controller: searchController, // Assign controller
                  decoration: InputDecoration(
                    hintText: text,
                    border: InputBorder.none, // No border for a clean look
                    hintStyle: TextStyle(color: MyColors.darkerGrey), // Hint text color
                    contentPadding: EdgeInsets.symmetric(vertical: 15), // Center text vertically
                  ),
                  style: TextStyle(fontSize: 12, color: Colors.black), // Font size for user input
                  onSubmitted: (value) {
                    if (onTap != null) {
                      onTap!(value); // Call the function on submit
                    }
                  },
                ),
              ),
=======
              const SizedBox(
                width: MySizes.spaceBtwItems,
              ),
              Text(text, style: Theme.of(context).textTheme.bodySmall),
>>>>>>> 8d9d7c4708cd91881283eb101aa12a4d80b10623
            ],
          ),
        ),
      ),
    );
  }
}
