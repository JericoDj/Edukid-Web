import 'package:flutter/material.dart';
import 'package:webedukid/utils/constants/colors.dart';


class MySectionHeading extends StatelessWidget {
  const MySectionHeading({
    super.key, this.textColor, this.showActionButton = true, required this.title, this.buttonTitle = 'View all', this.onPressed,
  });

  final Color? textColor;
  final bool showActionButton;
  final String title, buttonTitle;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      Text(title,
          style: Theme.of(context).textTheme.bodyLarge!.apply(color: textColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),



      if(showActionButton)TextButton(
          onPressed: onPressed,
          child: Text(buttonTitle,style: TextStyle(color: MyColors.primaryColor),)),
    ]);
  }
}
