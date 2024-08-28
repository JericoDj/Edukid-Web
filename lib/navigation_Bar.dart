
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'features/screens/homescreen/HomeScreen.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/order/order.dart';
import 'features/shop/screens/store/store.dart';

class NavigationBarMenu extends StatelessWidget {
  const NavigationBarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
            () => buildNavigationBar(navigationController),
      ),
      body: Obx(() => navigationController.screens[navigationController.selectedIndex.value]),
    );
  }

  Widget buildNavigationBar(NavigationController controller) {
    return NavigationBar(
      height: 80,
      elevation: 0,
      selectedIndex: controller.selectedIndex.value,
      onDestinationSelected: (index) => controller.selectedIndex.value = index,

      destinations: const [
        NavigationDestination(icon: Icon(Iconsax.home), label: "Home"),
        NavigationDestination(icon: Icon(Iconsax.shop), label: "Store"),
        NavigationDestination(icon: Icon(Iconsax.task), label: "Bookings"),
        NavigationDestination(icon: Icon(Iconsax.note), label: "Worksheets"),
        NavigationDestination(icon: Icon(Iconsax.user), label: "User"),
      ],
    );
  }
}
class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final screens = [
    const HomeScreen(),
    const StoreScreen(),
    const BookingsScreen(),
    const OrderScreen(),
    const SettingsScreen(),
  ];
}
