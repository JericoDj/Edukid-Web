import 'package:flutter/material.dart';
import 'package:webedukid/common/widgets/shimmer/shimmer.dart';

import '../../../utils/constants/sizes.dart';

class MyListTileShimmer extends StatelessWidget {
  const MyListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            MyShimmerEffect(width: 50, height: 50, radius: 50),
            SizedBox(width: MySizes.spaceBtwItems),
            Column(
              children: [
                MyShimmerEffect(width: 100, height: 15),
                SizedBox(height: MySizes.spaceBtwItems / 2),
                MyShimmerEffect(width: 80, height: 12),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
