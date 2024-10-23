
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';

class MyCircularIcon extends StatelessWidget {
  const MyCircularIcon({
    super.key,
    required this.icon, this.width, this.height, this.size, this.color, this.backroundColor, this.onPressed,
  });

  final double? width, height,size;
  final IconData icon;
  final Color? color;
  final Color? backroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backroundColor != null
          ? backroundColor!
        : MyHelperFunctions.isDarkMode(context)
          ? MyColors.black.withOpacity(0.9)
        : MyColors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular (100),
      ),// BoxDecoration
      child: IconButton (onPressed: onPressed, icon: Icon(icon, color:color, size:size)),
    );
  }
}