
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/screens/signup/widgets/signupform.dart';

import '../../../../common/widgets/divider_signinwith_text.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/login/login.dart';
import '../../../authentication/login/widgets/social_Media_Login.dart';


class SignUpScreen extends StatelessWidget {

  const SignUpScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MySizes.defaultspace),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 800,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(MyTexts.signUpTitle, style: Theme.of(context).textTheme.headlineMedium),

                  const SizedBox(height: MySizes.spaceBtwItems),

                  /// Sign Up Form/checkbox and Privacy/create account button
                  const SignUpForm(),


                  const SizedBox(height: MySizes.spaceBtwItems,),

                  /// Divider
                  const MyFormDivider(dividerText: "Or Sign In with",),

                  const SizedBox(height: MySizes.spaceBtwItems,),


                  const MySocialButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


