
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';

class MyShimmerEffect extends StatelessWidget {
  const MyShimmerEffect({
    Key? key,
    required this.width,
    required this.height,
    this.radius = 15,
    this.color,
  });

  final double width, height, radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    return Shimmer.fromColors(
      baseColor: dark ? MyColors.grey : MyColors.lightGrey,
      highlightColor: dark ? MyColors.grey : MyColors.lightGrey,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? (dark ? MyColors.darkerGrey : MyColors.lightGrey),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
