
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class MyVerticalImageText extends StatelessWidget {
  const MyVerticalImageText({
    Key? key, // Fix: Added the missing Key? key parameter
    required this.image,
    required this.title,
    this.textColor = MyColors.white,
    this.backgroundColor,
    this.onTap,
    this.isNetworkImage = true, // Added the isNetworkImage parameter
  }) : super(key: key);

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;
  final bool isNetworkImage; // Added the isNetworkImage parameter

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: MySizes.spaceBtwItems),
        child: Column(
          children: [
            /// circular Icon
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(MySizes.sm),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: isNetworkImage
                    ? Image.network(
                  image,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// Text
            const SizedBox(
              height: MySizes.spaceBtwItems / 2,
            ),
            SizedBox(
              width: 55,
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .apply(color: textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
