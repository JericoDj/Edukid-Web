
import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';


class MyCircularWidget extends StatelessWidget {
  const MyCircularWidget({
    super.key,


    this.child,
    this.width = 400,
    this.height = 400,
    this.radius = 400,
    this.padding = 0,
    this.margin,
    this.backroundColor = MyColors.white,
  });

  final double? width;
  final double? height;
  final double? radius;
  final double padding;
  final EdgeInsets? margin;
  final Widget? child;
  final Color backroundColor;


  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(400),
        color: backroundColor
      ),
      child: child ,
    );
  }
}