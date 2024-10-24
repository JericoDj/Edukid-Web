import 'package:flutter/material.dart';

class MyProductPriceText extends StatelessWidget {
  const MyProductPriceText({
    super.key,
    this.currencySign = '\$',
    required this.price,
    this.isLarge = false,
    this.maxLines = 1,
    this.lineThrough = false,
  });

  final String currencySign, price;
  final int maxLines;
  final bool isLarge;
  final bool lineThrough;

  @override
  Widget build(BuildContext context) {
    return Text(
      currencySign + price,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: isLarge
          ? Theme.of(context).textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        decoration: lineThrough ? TextDecoration.lineThrough : null,
      )
          : Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        decoration: lineThrough ? TextDecoration.lineThrough : null,
        color: Colors.green, // Adjust this if needed
      ),
    );
  }
}
