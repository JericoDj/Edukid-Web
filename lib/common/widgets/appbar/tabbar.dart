
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/device/device_utitility.dart';
import '../../../utils/helpers/helper_functions.dart';


class MyTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// If you want to add the background color to tabs you have to wrap them in Material widget.
  /// To do that we need [PreferredSized] Widget and that's why created custom class. [PreferredSizeWidget] const TTabBar({ super.key, required this.tabs});
  const MyTabBar({super.key, required this.tabs});


  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    return Material(
      color: dark ? MyColors.black : MyColors.white,
      child: TabBar(
        tabs: tabs,
        tabAlignment: TabAlignment.center,
        isScrollable: true,
        indicatorColor: MyColors.primaryColor,
        labelColor: dark ? MyColors.white : MyColors.primaryColor,
        unselectedLabelColor: MyColors.darkGrey,
      ), // TabBar
    );
  }
    //
    // Material
    @override Size get preferredSize => Size.fromHeight(MyDeviceUtils.getAppBarheight());
}