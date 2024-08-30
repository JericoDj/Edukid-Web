import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants/sizes.dart';

class MyGridLayoutWidget extends StatelessWidget {
  const MyGridLayoutWidget({
    super.key,
    required this.itemCount,
    this.mainAxisExtent = 320,
    required this.itemBuilder,
  });

  final int itemCount;
  final double? mainAxisExtent;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    // Calculate crossAxisCount based on screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 6 : 2; // Example logic

    return Center( // Wrap with Center to align grid in the center when itemCount is 1
      child: Container(

        constraints: BoxConstraints(
          maxWidth: itemCount == 1 ? 200 : double.infinity, // Adjust width if only one item
        ),
        child: GridView.builder(
          itemCount: itemCount,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: MySizes.spaceBtwSections * 0.3),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: itemCount == 1 ? 1 : crossAxisCount, // Set crossAxisCount to 1 if only one item
            mainAxisSpacing: MySizes.gridViewSpacing,
            crossAxisSpacing: MySizes.gridViewSpacing,
            mainAxisExtent: mainAxisExtent,
          ),
          itemBuilder: itemBuilder,
        ),
      ),
    );
  }
}
