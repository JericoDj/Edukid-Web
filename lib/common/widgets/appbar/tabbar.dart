import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/device/device_utitility.dart';
import '../../../utils/helpers/helper_functions.dart';

class MyTabBar extends StatelessWidget implements PreferredSizeWidget {
  const MyTabBar({super.key, required this.tabs, required this.controller});

  final List<Widget> tabs;
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    return Material(
      color: dark ? MyColors.black : MyColors.white,
      child: TabBar(
        tabAlignment: TabAlignment.center,
        controller: controller,
        tabs: tabs,
        isScrollable: true,
        indicatorColor: MyColors.primaryColor,
        labelColor: dark ? MyColors.white : MyColors.primaryColor,
        unselectedLabelColor: MyColors.darkGrey,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(MyDeviceUtils.getAppBarheight());
}
