import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/images/my_circular_image.dart';
import '../../../../utils/constants/sizes.dart';

class MyProfileMenu extends StatelessWidget {
  const MyProfileMenu({
    super.key,
    this.icon = Iconsax.arrow_right_34,
    required this.onPressed,
    required this.title,
    required this.value,
    this.showImage = false,
    this.imageUrl = '',
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String title, value;
  final bool showImage; // New property to check if we need to show an image
  final String imageUrl; // New property for image URL

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MySizes.spaceBtwItems / 1.5),
        child: Row(
          children: [
            // Display profile image if showImage is true
            if (showImage)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: MyCircularImage(
                  image: imageUrl, // Pass the imageUrl
                  isNetworkImage: true, // Assuming it's a network image
                  width: 40,
                  height: 40,
                ),
              ),
            Expanded(child: Text(title)),
            Expanded(child: Text(value)),
            Expanded(child: Icon(icon, size: 18)),
          ],
        ),
      ),
    );
  }
}
