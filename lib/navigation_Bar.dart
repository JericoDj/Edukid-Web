import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/editprofile.dart';
import 'package:webedukid/utils/constants/colors.dart';

import 'common/widgets/customShapes/containers/search_container.dart';
import 'features/screens/gamesscreen/games screen.dart';
import 'features/screens/homescreen/HomeScreen.dart';
import 'features/screens/navigation_controller.dart';
import 'features/screens/personalization/screens/address/address.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/shop/cart/cart.dart';
import 'features/shop/controller/product/product_controller.dart';
import 'features/shop/screens/account_privacy/account_privacy_screen.dart';
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/coupons/coupons_screen.dart';
import 'features/shop/screens/order/order.dart';
import 'features/shop/screens/store/store.dart';
import 'features/shop/screens/bookings/booking_session.dart';
import 'features/shop/screens/all_products/all_products.dart';
import 'features/shop/screens/wishlist/wishlist.dart';



class NavigationBarMenu extends StatefulWidget implements PreferredSizeWidget {
  @override
  _NavigationBarMenuState createState() => _NavigationBarMenuState();

  @override
  Size get preferredSize => Size.fromHeight(300); // Further increase the height
}

class _NavigationBarMenuState extends State<NavigationBarMenu> {
  bool _isDrawerOpen = false;

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _navigateToEditProfile() {
    Get.find<NavigationController>().navigateTo('editProfile');
  }

  void _navigateToUserAddress() {
    Get.find<NavigationController>().navigateTo('userAddress');
  }

  void _navigateToCart() {
    Get.find<NavigationController>().navigateTo('cart');
  }

  void _navigateToOrder() {
    Get.find<NavigationController>().navigateTo('order');
  }

  void _navigateToWishlist() {
    Get.find<NavigationController>().navigateTo('wishlist');
  }

  void _navigateToCoupon() {
    Get.find<NavigationController>().navigateTo('coupon');
  }

  void _navigateToAccountPrivacy() {
    Get.find<NavigationController>().navigateTo('accountPrivacy');
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
      'bookingSession': () =>
          BookingSessionScreen(selectedDates: [], selectedTimes: []),
      'allProducts': () {
        Get.lazyPut(() => ProductController());
        return AllProductsScreen(
          title: 'Popular Products',
          futureMethod:
          Get.find<ProductController>().fetchAllFeaturedProducts(),
        );
      },
      'games': () => GamesScreen(),
      'editProfile': () => EditProfileScreen(),
      'userAddress': () => UserAddressScreen(),
      'wishlist': () => WishlistScreen(),
      'coupon': () => CouponScreen(),
      'accountPrivacy': () => AccountPrivacyScreen(),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                  _buildNavButton('games', Iconsax.game, 'Games'),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                  icon: Icon(Iconsax.user, color: Colors.white),
                  onPressed: _toggleDrawer,
                ),
                SizedBox(width: 10)
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
            onEditProfile: _navigateToEditProfile,
            onUserAddress: _navigateToUserAddress,
            onCart: _navigateToCart,
            onOrder: _navigateToOrder,
            onWishlist: _navigateToWishlist,
            onCoupon: _navigateToCoupon,
            onAccountPrivacy: _navigateToAccountPrivacy,
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
          color: navigationController.currentScreen.value == screenKey
              ? Colors.yellow
              : Colors.white,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: navigationController.currentScreen.value == screenKey
                ? Colors.yellow
                : Colors.white,
          ),
        ),
        onPressed: () {
          navigationController.navigateTo(screenKey);
        },
      );
    });
  }
}
