import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pollex/Providers/db_provider.dart';
import 'package:pollex/Providers/fetch_polls_provider.dart';
import 'package:pollex/Styles/colors.dart';
import 'package:pollex/Utils/dynamic_utils.dart';
import 'package:pollex/Utils/message.dart';
import 'package:pollex/Utils/router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../MyPolls/add_new_polls.dart';

import 'package:pollex/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isFetched = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // TODO: Implement _loadRewardedAd()
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              nextPage(context, const AddPollPage());
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
    _loadRewardedAd();
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: SvgPicture.asset("assets/logo.svg"),
      ),
      body: Consumer<FetchPollsProvider>(builder: (context, polls, child) {
        if (_isFetched == false) {
          polls.fetchAllPolls();

          Future.delayed(const Duration(microseconds: 1), () {
            _isFetched = true;
          });
        }
        return SafeArea(
          child: polls.isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : polls.pollsList.isEmpty
                  ? const Center(
                      child: Text("No polls at the moment"),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            // color: Colors.red,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                if (_bannerAd != null)
                                  Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      // color: Colors.yellow,

                                      width: _bannerAd!.size.width.toDouble(),
                                      height: _bannerAd!.size.height.toDouble(),
                                      child: AdWidget(ad: _bannerAd!),
                                    ),
                                  ),
                                SizedBox(
                                  height: 15.00,
                                ),
                                
                                ...List.generate(polls.pollsList.length,
                                    (index) {
                                  final data = polls.pollsList[index];

                                  log(data.data().toString());
                                  Map author = data["author"];
                                  Map poll = data["poll"];
                                  Timestamp date = data["dateCreated"];

                                  List voters = poll["voters"];

                                  List<dynamic> options = poll["options"];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 25),
                                    padding: const EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border:
                                            Border.all(color: AppColors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(0),
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                author["profileImage"]),
                                          ),
                                          title: Text(author["name"]),
                                          subtitle: Text(DateFormat.yMEd()
                                              .format(date.toDate())),
                                          // trailing: IconButton(
                                          //     onPressed: () {
                                          //       ///
                                          //       DynamicLinkProvider()
                                          //           .createLink(data.id)
                                          //           .then((value) {
                                          //         Share.share(value);
                                          //       });
                                          //     },
                                          //     icon: const Icon(Icons.share)),
                                        ),
                                        Text(
                                          poll["question"],
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        ...List.generate(options.length,
                                            (index) {
                                          final dataOption = options[index];
                                          return Consumer<DbProvider>(
                                              builder: (context, vote, child) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                              (_) {
                                                if (vote.message != "") {
                                                  if (vote.message.contains(
                                                      "Vote Recorded")) {
                                                    success(context,
                                                        message: vote.message);
                                                    polls.fetchAllPolls();
                                                    vote.clear();
                                                  } else {
                                                    error(context,
                                                        message: vote.message);
                                                    vote.clear();
                                                  }
                                                }
                                              },
                                            );
                                            return GestureDetector(
                                              onTap: () {
                                                log(user!.uid);

                                                ///Update vote
                                                if (voters.isEmpty) {
                                                  log("No vote");
                                                  vote.votePoll(
                                                      pollId: data.id,
                                                      pollData: data,
                                                      previousTotalVotes:
                                                          poll["total_votes"],
                                                      seletedOptions:
                                                          dataOption["answer"]);
                                                } else {
                                                  final isExists =
                                                      voters.firstWhere(
                                                          (element) =>
                                                              element["uid"] ==
                                                              user!.uid,
                                                          orElse: () {});
                                                  if (isExists == null) {
                                                    log("User does not exist");
                                                    vote.votePoll(
                                                        pollId: data.id,
                                                        pollData: data,
                                                        previousTotalVotes:
                                                            poll["total_votes"],
                                                        seletedOptions:
                                                            dataOption[
                                                                "answer"]);
                                                    //
                                                  } else {
                                                    error(context,
                                                        message:
                                                            "You have already voted");
                                                  }
                                                  print(isExists.toString());
                                                }
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                width: size.width * 0.75,
                                                color: Color(0xffeeeeee),
                                                margin: const EdgeInsets.only(
                                                    bottom: 10, left: 15),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Stack(
                                                        children: [
                                                          LinearProgressIndicator(
                                                            minHeight: 40,
                                                            value: dataOption[
                                                                    "percent"] /
                                                                100,
                                                            backgroundColor:
                                                                Color(
                                                                    0xffeeeeee),
                                                          ),
                                                          Container(
                                                            // color: Colors.blue,
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            height: 50,
                                                            child: Text(
                                                                dataOption[
                                                                    "answer"]),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Text(
                                                        "${dataOption["percent"]}%")
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        }),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Color(0xffeeeeee),
                                              ),
                                              child: Text(
                                                "Total votes : ${poll["total_votes"]}",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Color(0xffeeeeee),
                                              ),
                                              child: IconButton(
                                                  onPressed: () {
                                                    ///
                                                    DynamicLinkProvider()
                                                        .createLink(data.id)
                                                        .then((value) {
                                                      Share.share(value);
                                                    });
                                                  },
                                                  icon:
                                                      const Icon(Icons.share)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                })
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_interstitialAd != null) {
            _interstitialAd?.show();
          } else {
            nextPage(context, const AddPollPage());
            print("ad not found");
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
