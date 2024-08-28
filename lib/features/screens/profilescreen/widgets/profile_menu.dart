
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/sizes.dart';


class MyProfileMenu extends StatelessWidget {
  const MyProfileMenu({
    super.key,
    this.icon = Iconsax.arrow_right_34,
    required this.onPressed,
    required this.title,
    required this.value,
  });



  final IconData icon;
  final VoidCallback onPressed;
  final String title, value;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MySizes.spaceBtwItems / 1.5),
        child: Row(
          children: [
            Expanded(
                child: Text(title)),
            Expanded(
                child: Text(value)) ,
            Expanded(child: Icon(icon, size: 18,)),
          ],
        ),
      ),
    );
  }
}
