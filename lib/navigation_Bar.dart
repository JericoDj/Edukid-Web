import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/utils/constants/colors.dart';

import 'common/widgets/customShapes/containers/search_container.dart';
import 'features/screens/homescreen/HomeScreen.dart';
import 'features/screens/navigation_controller.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/shop/cart/cart.dart';
import 'features/shop/controller/product/product_controller.dart';
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/order/order.dart';
import 'features/shop/screens/store/store.dart';
import 'features/shop/screens/bookings/booking_session.dart';
import 'features/shop/screens/all_products/all_products.dart';

class NavigationBarMenu extends StatefulWidget implements PreferredSizeWidget {
  @override
  _NavigationBarMenuState createState() => _NavigationBarMenuState();

  @override
  Size get preferredSize => Size.fromHeight(300);  // Further increase the height
}

class _NavigationBarMenuState extends State<NavigationBarMenu> {
  bool _isDrawerOpen = false;

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => NavigationController());

    final NavigationController navigationController = Get.find();

    final Map<String, Widget Function()> screens = {
      'home': () => HomeScreen(),
      'store': () => StoreScreen(),
      'bookings': () => BookingsScreen(),
      'order': () => OrderScreen(),
      'cart': () => CartScreen(),
      'bookingSession': () => BookingSessionScreen(selectedDates: [], selectedTimes: []),
      'allProducts': () {
        Get.lazyPut(() => ProductController());
        return AllProductsScreen(
          title: 'Popular Products',
          futureMethod: Get.find<ProductController>().fetchAllFeaturedProducts(),
        );
      },
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,  // Center vertically
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Image.asset(
                'assets/EdukidLogo.jpg',
                height: 50,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildNavButton('home', Iconsax.home, 'Home'),
                  _buildNavButton('store', Iconsax.shop, 'Store'),
                  _buildNavButton('bookings', Iconsax.task, 'Bookings'),
                  _buildNavButton('order', Iconsax.note, 'Worksheets'),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),  // Adjust padding for better alignment
                child: MySearchContainer(text: ' Search for Items'),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Iconsax.shopping_cart, color: Colors.white),
                  onPressed: () {
                    navigationController.navigateTo('cart');
                  },
                ),
                IconButton(
                  icon: Icon(Iconsax.setting_2, color: Colors.white),
                  onPressed: _toggleDrawer,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Obx(() => screens[navigationController.currentScreen.value]!()),
          SettingsScreen(
            isOpen: _isDrawerOpen,
            onClose: _toggleDrawer,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String screenKey, IconData icon, String label) {
    final NavigationController navigationController = Get.find();
    return Obx(() {
      return TextButton.icon(
        icon: Icon(
          icon,
          color: navigationController.currentScreen.value == screenKey ? Colors.yellow : Colors.white,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: navigationController.currentScreen.value == screenKey ? Colors.yellow : Colors.white,
          ),
        ),
        onPressed: () {
          navigationController.navigateTo(screenKey);
        },
      );
    });
  }
}
