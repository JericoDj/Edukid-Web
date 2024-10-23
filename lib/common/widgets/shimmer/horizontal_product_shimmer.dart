
import 'package:flutter/material.dart';
import 'package:webedukid/common/widgets/shimmer/shimmer.dart';

import '../../../utils/constants/sizes.dart';

class MyHorizontalProductShimmer extends StatelessWidget {
  const MyHorizontalProductShimmer({
    Key? key,
    this.itemCount = 4,
  }) : super(key: key);

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: MySizes.spaceBtwSections),
      height: 120,
      child: ListView.separated(
        itemCount: itemCount,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: MySizes.spaceBtwItems),
        itemBuilder: (_, __) => Container(
          width: 300,  // Adjust this width as needed
          child: Row(
            children: [
              MyShimmerEffect(width: 120, height: 120),
              SizedBox(width: MySizes.spaceBtwItems),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyShimmerEffect(width: 160, height: 15),
                  MyShimmerEffect(width: 110, height: 15),
                  MyShimmerEffect(width: 80, height: 15),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


