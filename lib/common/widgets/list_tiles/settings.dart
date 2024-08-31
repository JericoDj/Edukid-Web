
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';

class MySettingsMenuTile extends StatelessWidget {
  const MySettingsMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.trailing,
    this.onTap,
  });


  final IconData icon;
  final String title, subTitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24, color: MyColors.primaryColor),
      title: Text(title, style: Theme
          .of(context)
          .textTheme
          .bodyMedium),
      subtitle: Text(subTitle, style: Theme
          .of(context)
          .textTheme
          .labelSmall),
      trailing: trailing,
      onTap: onTap,
    ); // ListTile
  }
}
