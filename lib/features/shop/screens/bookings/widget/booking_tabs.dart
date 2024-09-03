
import 'package:flutter/material.dart';
import 'package:webedukid/utils/constants/colors.dart';

import '../../../../bookings/widgets/bookings_list.dart';

class TabData {
  final String label;
  final IconData icon;

  const TabData({required this.label, required this.icon});
}

class MyTabContentView extends StatelessWidget {
  final List<String> content;
  final int selectedIndex;

  const MyTabContentView({
    Key? key,
    required this.content,
    required this.selectedIndex, required MyBookingsList child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(content[selectedIndex]),
    );
  }
}

class MyTabBookingBar extends StatelessWidget {
  final List<TabData> tabs;
  final void Function(int) onTabSelected;
  final int selectedIndex;

  const MyTabBookingBar({
    Key? key,
    required this.tabs,
    required this.onTabSelected,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int index = 0; index < tabs.length; index++)
            InkWell(
              onTap: () => onTabSelected(index),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabs[index].icon,
                      color:
                      index == selectedIndex ? MyColors.primaryColor : Colors.grey,
                    ),
                    SizedBox(height: 5),
                    Text(
                      tabs[index].label,
                      style: TextStyle(
                        color: index == selectedIndex
                            ? MyColors.primaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
