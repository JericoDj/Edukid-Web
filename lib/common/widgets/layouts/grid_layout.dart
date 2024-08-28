
import 'package:flutter/cupertino.dart';

import '../../../utils/constants/sizes.dart';

class MyGridLayoutWidget extends StatelessWidget {
  const MyGridLayoutWidget({super.key,
    required this.itemCount,
    /// this means height
    this.mainAxisExtent = 320,
    required this.itemBuilder,
  });

  final int itemCount;
  final double? mainAxisExtent;

  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: MySizes.spaceBtwSections * 0.3),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: MySizes.gridViewSpacing,
        crossAxisSpacing: MySizes.gridViewSpacing,
        mainAxisExtent: mainAxisExtent,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
