import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pollex/Providers/authentication_provider.dart';
import 'package:pollex/Screens/main_activity_page.dart';
import 'package:pollex/Styles/colors.dart';
import 'package:pollex/Utils/message.dart';
import 'package:pollex/Utils/router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        
        child: Column(
          children: [
            SvgPicture.asset("assets/welcome.svg"),
            Text("Welcome to the Pollex", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
            SizedBox(height: 20,),
            GestureDetector(
              onTap: () {
                AuthProvider().signInWithGoogle().then((value) {
                  if (value.user == null) {
                    error(context, message: "Please try again");
                  } else {
                    nextPageOnly(context, const MainActivityPage());
                  }
                });
              },
              child: Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/google.png", width: 25, height: 25,),
                    SizedBox(width: 10,),
                    const Text("Login with Google", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
     Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();}
  }
}
