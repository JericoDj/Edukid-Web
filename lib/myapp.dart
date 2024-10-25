import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

import 'common/widgets/appbar/tabbar.dart';
import 'drawer_controller.dart';
import 'features/authentication/login/login.dart';
import 'features/authentication/password_configuration/forget_password.dart';
import 'features/screens/gamesscreen/games screen.dart';
import 'features/screens/homescreen/HomeScreen.dart';
import 'features/screens/navigation_controller.dart';
import 'features/screens/personalization/screens/address/address.dart';
import 'features/screens/profilescreen/settings.dart';
import 'features/screens/signup/widgets/signup.dart';
import 'features/shop/cart/cart.dart';
import 'features/shop/controller/category_controller.dart';
import 'features/shop/controller/product/cart_controller.dart';
import 'features/shop/controller/product/variation_controller.dart';
import 'features/shop/screens/account_privacy/account_privacy_screen.dart';
import 'features/shop/screens/booking_checkout/booking_checkout.dart';
import 'features/shop/screens/bookings/booking_session.dart';
import 'features/shop/screens/bookings/bookings.dart';
import 'features/shop/screens/coupons/coupons_screen.dart';
import 'features/shop/screens/order/all_orders_screen.dart';
import 'features/shop/screens/order/order.dart';
import 'features/shop/screens/wishlist/wishlist.dart';
import 'navigation_Bar.dart';

final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(key: appKey));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final drawerController = Get.put(MyDrawerController());

  void restartApp() {
    setState(() {}); // Rebuilds the app
  }


  @override
  Widget build(BuildContext context) {
    // Initialize other controllers if necessary
    Get.lazyPut(() => VariationController());
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => CategoryController());
    Get.lazyPut(() => NavigationController());

    final GoRouter router = GoRouter(
      initialLocation: '/home',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Scaffold(
              appBar: NavigationBarMenu(),
              endDrawerEnableOpenDragGesture: true,
              endDrawer: Obx(() => Drawer(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: SettingsScreen(
                  isOpen: drawerController.isDrawerOpen.value,
                  onClose: () => drawerController.closeDrawer(),
                  onEditProfile: () => setState(() {}),
                  onUserAddress: () => context.go('/userAddress'),
                  onCart: () => context.go('/cart'),
                  onOrder: () => context.go('/allOrders'),
                  onWishlist: () => context.go('/wishlist'),
                  onCoupon: () => context.go('/coupon'),
                  onAccountPrivacy: () => context.go('/accountPrivacy'),
                ),
              )),
              body: child,
            );
          },
          routes: [
            GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
            GoRoute(path: '/store', builder: (context, state) => const StoreScreen()),
            GoRoute(path: '/bookings', builder: (context, state) => const BookingsScreen()),
            GoRoute(path: '/order', builder: (context, state) => OrderScreen(isInteractive: true)),
            GoRoute(path: '/games', builder: (context, state) => const GamesScreen()),
            GoRoute(path: '/cart', builder: (context, state) => CartScreen()),
            GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
            GoRoute(path: '/register', builder: (context, state) => SignUpScreen()),
            GoRoute(path: '/forgotPassword', builder: (context, state) => ForgetPasswordScreen()),
            GoRoute(path: '/userAddress', builder: (context, state) => UserAddressScreen()),
            GoRoute(path: '/allOrders', builder: (context, state) => AllOrdersScreen(isInteractive: true)),
            GoRoute(path: '/wishlist', builder: (context, state) => WishlistScreen()),
            GoRoute(path: '/coupon', builder: (context, state) => CouponScreen()),
            GoRoute(path: '/accountPrivacy', builder: (context, state) => AccountPrivacyScreen()),
            GoRoute(path: '/bookSession', builder: (context, state) => BookingSessionScreen()),
            GoRoute(
              path: '/bookingCheckout',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                final pickedDates = (extra?['pickedDates'] as List).map((date) => date as DateTime).toList();
                final pickedTimes = (extra?['pickedTimes'] as List).map((time) => time as TimeOfDay).toList();
                final price = extra?['price'] as double? ?? 0.0;

                return BookingCheckOutScreen(
                  pickedDates: pickedDates,
                  pickedTimes: pickedTimes,
                  price: price,
                );
              },
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
