import 'dart:ui';  // For ImageFilter (blur effect)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'common/widgets/customShapes/containers/search_container.dart';
import 'features/screens/navigation_controller.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/authentication/login/login.dart';
import 'package:webedukid/common/data/repositories.authentication/authentication_repository.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? title;
  final String currentScreen;

  CustomAppBar({required this.currentScreen, this.title});

  @override
  CustomAppBarState createState() => CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class CustomAppBarState extends State<CustomAppBar> {
  bool _isDrawerOpen = false;
  bool isInteractive = true;

  void toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      isInteractive = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true, // Make body extend behind the app bar
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        titleSpacing: 0,
        elevation: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: GestureDetector(
                onTap: () => _navigateToScreen('home', '/home'),
                child: Image.asset('assets/EdukidLogo.jpg', height: 50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildNavButton('home', Iconsax.home, 'Home', '/home'),
                  _buildNavButton('store', Iconsax.shop, 'Store', '/store'),
                  _buildNavButton('bookings', Iconsax.calendar, 'Bookings', '/bookings'),
                  _buildNavButton('order', Iconsax.note, 'Worksheets', '/order'),
                  _buildNavButton('games', Iconsax.game, 'Games', '/games'),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: MySearchContainer(text: 'Search for Items'),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.shopping_cart, color: Colors.white),
                  onPressed: () {
                    context.push('/cart');
                  },
                ),
                IconButton(
                  icon: const Icon(Iconsax.user, color: Colors.white),
                  onPressed: () {
                    toggleDrawer(); // Toggle the drawer state
                  },
                ),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [


          // Transparent backdrop filter to blur background when drawer opens
          if (_isDrawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: toggleDrawer,  // Close drawer when clicking outside
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
            ),

          // Custom drawer overlay
          if (_isDrawerOpen)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 300, // Drawer width
              child: Material(
                elevation: 10,
                color: Colors.white, // Drawer color
                child: SettingsScreen(
                  isOpen: _isDrawerOpen,
                  onClose: toggleDrawer,
                  onEditProfile: () => navigationController.navigateTo('editProfile'),
                  onUserAddress: () => navigationController.navigateTo('userAddress'),
                  onCart: () => navigationController.navigateTo('cart'),
                  onOrder: () => navigationController.navigateTo('allOrders'),
                  onWishlist: () => navigationController.navigateTo('wishlist'),
                  onCoupon: () => navigationController.navigateTo('coupon'),
                  onAccountPrivacy: () => navigationController.navigateTo('accountPrivacy'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Navigation Button Builder with Icons
  Widget _buildNavButton(String screenKey, IconData icon, String label, String route) {
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
          _navigateToScreen(screenKey, route);
        },
      );
    });
  }

  // Handle Navigation
  void _navigateToScreen(String screenKey, [String? route]) {
    final NavigationController navigationController = Get.find();

    if (navigationController.currentScreen.value == screenKey) {
      navigationController.currentScreen.value = '';
      Future.delayed(const Duration(milliseconds: 100), () {
        navigationController.currentScreen.value = screenKey;
      });
    } else {
      navigationController.currentScreen.value = screenKey;
      if (route != null) {
        context.push(route);
      }
    }
  }
}
