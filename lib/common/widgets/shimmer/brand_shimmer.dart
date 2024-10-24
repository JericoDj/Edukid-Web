
import 'package:flutter/material.dart';
import 'package:webedukid/common/widgets/shimmer/shimmer.dart';

import '../layouts/grid_layout.dart';

class MyBrandShimmer extends StatelessWidget {
  const MyBrandShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return MyGridLayoutWidget(
      mainAxisExtent: 80,
        itemCount: itemCount,
      itemBuilder: (_, __) => const MyShimmerEffect(width: 300, height: 80),
    );
  }
}
