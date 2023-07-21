import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:pollex/Providers/db_provider.dart';
import 'package:pollex/Screens/BottomNavPages/MyPolls/add_new_polls.dart';
import 'package:pollex/Styles/colors.dart';
import 'package:pollex/Utils/message.dart';
import 'package:pollex/Utils/router.dart';
import 'package:provider/provider.dart';
import 'package:pollex/ad_helper.dart';
import 'package:pollex/Screens/BottomNavPages/Home/home_page.dart';
import '../../../Providers/fetch_polls_provider.dart';
import 'package:pollex/quiz/answer.dart';

class MyPolls extends StatefulWidget {
  const MyPolls({super.key});

  @override
  State<MyPolls> createState() => _MyPollsState();
}

class _MyPollsState extends State<MyPolls> {
  List<Icon> _scoreTracker = [];
  int _questionIndex = 0;
  int _totalScore = 0;
  bool answerWasSelected = false;
  bool endOfQuiz = false;
  bool correctAnswerSelected = false;

  void _questionAnswered(bool answerScore) {
    setState(() {
      // answer was selected
      answerWasSelected = true;
      // check if answer was correct
      if (answerScore) {
        _totalScore++;
        correctAnswerSelected = true;
      }
      // adding to the score tracker on top
      _scoreTracker.add(
        answerScore
            ? Icon(
                Icons.check_circle,
                color: Colors.green,
              )
            : Icon(
                Icons.clear,
                color: Colors.redAccent,
              ),
      );
      //when the quiz ends
      if (_questionIndex + 1 == _questions.length) {
        endOfQuiz = true;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _questionIndex++;
      answerWasSelected = false;
      correctAnswerSelected = false;
    });
    // what happens at the end of the quiz
    if (_questionIndex >= _questions.length) {
      _resetQuiz();
    }
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
      _scoreTracker = [];
      endOfQuiz = false;
    });
  }

  RewardedAd? _rewardedAd;

  BannerAd? _bannerAd;
  bool _isFetched = false;
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

  @override
  void dispose() {
    // COMPLETE: Dispose a BannerAd object
    _bannerAd?.dispose();

    // COMPLETE: Dispose an InterstitialAd object

    // COMPLETE: Dispose a RewardedAd object
    _rewardedAd?.dispose();

    // QuizManager.instance.listener = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FetchPollsProvider>(builder: (context, polls, child) {
        if (_isFetched == false) {
          polls.fetchUserPolls();

          Future.delayed(const Duration(microseconds: 1), () {
            _isFetched = true;
          });
        }
        return SafeArea(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(children: [
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
                ]),
                SizedBox(
                  height: 15.00,
                ),
                Container(
                  width: double.infinity,
                  height: 200.0,
                  margin:
                      EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://img.freepik.com/premium-photo/empty-baseball-stadium-arena-with-fans-crowd-sunny-day-lights_336913-605.jpg?w=2000'),
                      fit: BoxFit.cover,
                      opacity: 10,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xffeeeeee),
                  ),
                  child: Center(
                    child: Text(
                      _questions[_questionIndex]['question'].toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ...(_questions[_questionIndex]['answers']
                        as List<Map<String, Object>>)
                    .map(
                  (answer) => Answer(
                    answerText: answer['answerText'].toString(),
                    // answerColor:
                    // answerWasSelected
                    //     ? answer['score']
                    //     ? Colors.green
                    //     : Colors.red
                    //     : null,
                    answerTap: () {
                      // if answer was already selected then nothing happens onTap
                      if (answerWasSelected) {
                        return;
                      }
                      //answer is being selected
                      // _questionAnswered(answer['score']);
                    },
                    answerColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200.00, 40.0),
                      backgroundColor: Color(0xFF1DA1F2),
                      shadowColor: Color(0xFF1DA1F2),
                    ),
                    onPressed: () {
                      if (!answerWasSelected) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Please select an answer before going to the next question'),
                        ));
                        return;
                      }
                      _nextQuestion();
                    },
                    child: Text(endOfQuiz ? 'Submit' : 'Submit'),
                  ),
                ),
                if (answerWasSelected && !endOfQuiz)
                  Container(
                    height: 100,
                    width: double.infinity,
                    color:
                        correctAnswerSelected ? Colors.green : Colors.redAccent,
                    child: Center(
                      child: Text(
                        correctAnswerSelected
                            ? 'Well done,Sahi Pakde Hai!'
                            : 'Lol Galat  !:/',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (endOfQuiz)
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        _totalScore > 4
                            ? 'Congratulations! Your final score is: $_totalScore'
                            : 'Your final score is: $_totalScore. Better luck next time!',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color:
                              _totalScore > 4 ? Colors.green : Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
      //  floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //                     Navigator.pop(context);
      //                     _rewardedAd?.show(
      //                       onUserEarnedReward: (_, reward) {
      //                       //  QuizManager.instance.useHint();
      //                       },
      //                     );
      //                   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}

final _questions = const [
  {
    'question': 'Who Will Win The Match?',
    'answers': [
      {'answerText': 'INDIA', 'score': false},
      {'answerText': 'Bangladesh', 'score': true},
    ],
  },
  {
    'question': 'Who created Stranger Things?',
    'answers': [
      {'answerText': 'The Duffer Brothers', 'score': true},
      {'answerText': 'Alex Pina', 'score': false},
      {'answerText': 'Steven Knight', 'score': false},
    ],
  },
];
