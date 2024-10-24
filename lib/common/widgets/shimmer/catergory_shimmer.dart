
import 'package:flutter/material.dart';
import 'package:webedukid/common/widgets/shimmer/shimmer.dart';

import '../../../utils/constants/sizes.dart';

class MyCategoryShimmer extends StatelessWidget {
  const MyCategoryShimmer({
    Key? key, // Fix: Added the missing Key? key parameter
    this.itemCount = 6,
  }) : super(key: key); // Fix: Corrected the position of the super constructor

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: itemCount,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: MySizes.spaceBtwItems),
        itemBuilder: (_, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Image
              MyShimmerEffect(width: 55, height: 55, radius: 55),
              SizedBox(height: MySizes.spaceBtwItems / 2),

              MyShimmerEffect(width: 55, height: 8),
            ], // Fix: Added the missing closing square bracket
          );
        },
      ),
    );
  }
}
