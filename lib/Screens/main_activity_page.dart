import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pollex/Providers/authentication_provider.dart';
import 'package:pollex/Providers/bottom_nav_provider.dart';
import 'package:pollex/Screens/BottomNavPages/Account/accounts_page.dart';
import 'package:pollex/Screens/BottomNavPages/Home/home_page.dart';
import 'package:pollex/Screens/BottomNavPages/MyPolls/my_polls.dart';
import 'package:provider/provider.dart';
import 'package:pollex/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainActivityPage extends StatefulWidget {
  const MainActivityPage({super.key});

  @override
  State<MainActivityPage> createState() => _MainActivityPageState();
}

class _MainActivityPageState extends State<MainActivityPage> {
  BannerAd? _bannerAd;
  @override
  void initState() {
    super.initState();
     BannerAd(
    adUnitId: AdHelper.bannerAdUnitId,
    request: AdRequest(),
    size: AdSize.banner,
    listener: BannerAdListener(
      onAdLoaded: (ad) {
        setState(() {
          _bannerAd = ad as BannerAd;
        });
      },
      onAdFailedToLoad: (ad, err) {
        print('Failed to load a banner ad: ${err.message}');
        ad.dispose();
      },
    ),
  ).load();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavProvider>(builder: (context, nav, child) {
      return Scaffold(
        body: _pages[nav.currentIndex],
        bottomNavigationBar:
        BottomNavigationBar(
          items: _items,
          currentIndex: nav.currentIndex,
          onTap: (value) {
            nav.changeIndex = value;
          },
        ),
      );
    });
  }

  List<Widget> _pages = [HomePage(), MyPolls(), AccountPage()];

  List<BottomNavigationBarItem> _items = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.sports_basketball), label: "My Polls"),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
  ];
}
