import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'features/screens/gamesscreen/games screen.dart';
import 'features/screens/homescreen/HomeScreen.dart';  // Import your actual HomeScreen widget
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/order/order.dart';
import 'features/shop/screens/store/store.dart';  // Import your OrdersScreen widget

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentScreen;  // Tracks the currently active screen
  final bool isInteractive;    // Control for pointerEvents based on drawer state

  // Constructor to initialize the active screen and isInteractive
  CustomAppBar({required this.currentScreen, this.isInteractive = true});

  // Specify the size of the app bar (height)
  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: MyColors.primaryColor,
      titleSpacing: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              child: Image.asset('assets/EdukidLogo.jpg', height: 50),
              onTap: () => Get.to(HomeScreen()),  // Navigate to HomeScreen directly
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  onPressed:() => Get.to(HomeScreen()), // Navigate to HomeScreen
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Home',
                      style: TextStyle(
                        color: currentScreen == 'home' ? Colors.yellow : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(StoreScreen()),  // Navigate to StoreScreen
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Store',
                      style: TextStyle(
                        color: currentScreen == 'store' ? Colors.yellow : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(BookingsScreen()),  // Navigate to BookingsScreen
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Bookings',
                      style: TextStyle(
                        color: currentScreen == 'bookings' ? Colors.yellow : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(OrderScreen(isInteractive: isInteractive)),  // Navigate to OrdersScreen
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Worksheets',
                      style: TextStyle(
                        color: currentScreen == 'order' ? Colors.yellow : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(GamesScreen()),  // Navigate to GamesScreen
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Games',
                      style: TextStyle(
                        color: currentScreen == 'games' ? Colors.yellow : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
