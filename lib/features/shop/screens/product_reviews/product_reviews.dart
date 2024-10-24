
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/shop/screens/product_reviews/widgets/rating_progress_indicator.dart';
import 'package:webedukid/features/shop/screens/product_reviews/widgets/user_review_card.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/products/ratings/rating_indicator.dart';
import '../../../../utils/constants/sizes.dart';

class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// AppBar
      appBar: MyAppBar(title: Text('Reviews & Ratings'), showBackArrow: true),

      /// Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MySizes.defaultspace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ratings and reviews are verified and are from people who use the same type of device that you use."),
              const SizedBox(height: MySizes.spaceBtwItems),

              /// Overall Product Ratings
              OverallProductRatings(),
              MyRatingBarIndicator(rating: 3.5,),
              Text('12,523',style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: MySizes.spaceBtwSections,),


              ///user Reviews List
              UserReviewCard(),
              UserReviewCard(),



            ],
          ),
        ),
      ),
    );
  }
}



