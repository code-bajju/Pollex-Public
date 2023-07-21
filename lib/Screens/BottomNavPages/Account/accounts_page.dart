import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pollex/Providers/authentication_provider.dart';
import 'package:pollex/Providers/db_provider.dart';
import 'package:pollex/Providers/fetch_polls_provider.dart';
import 'package:pollex/Screens/Authentication/auth_page.dart';
import 'package:pollex/Screens/main_activity_page.dart';
import 'package:pollex/Screens/splash_screen.dart';
import 'package:pollex/Styles/colors.dart';
import 'package:pollex/Utils/message.dart';
import 'package:pollex/Utils/router.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isFetched = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My profile",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<FetchPollsProvider>(builder: (context, polls, child) {
        if (_isFetched == false) {
          polls.fetchUserPolls();

          Future.delayed(const Duration(microseconds: 1), () {
            _isFetched = true;
          });
        }
        return SafeArea(
          child: polls.isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : polls.userPollsList.isEmpty
                  ? const Center(
                      child: Text("No polls at the moment"),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                ...List.generate(polls.userPollsList.length,
                                    (index) {
                                  final data = polls.userPollsList[index];

                                  log(data.data().toString());
                                  Map author = data["author"];

                                  return Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 40.0,
                                        backgroundImage: NetworkImage(
                                            author["profileImage"]),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        author["name"],
                                        style: TextStyle(fontSize: 24),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  );
                                }),
                                GestureDetector(
                                  onTap: () {
                                    AuthProvider().logOut().then((value) {
                                      // if (value == false) {
                                      //   error(context, message: "Please try again");
                                      // } else {
                                      nextPageOnly(
                                          context, const SplashScreen());
                                      // }
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    alignment: Alignment.center,
                                    child: const Text("Log Out", style: TextStyle(color: Colors.white),),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  width: size.width,
                                  child: Text(
                                    "My Polls",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                ...List.generate(polls.userPollsList.length,
                                    (index) {
                                  final data = polls.userPollsList[index];

                                  log(data.data().toString());
                                  Map author = data["author"];
                                  Map poll = data["poll"];
                                  Timestamp date = data["dateCreated"];

                                  List<dynamic> options = poll["options"];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
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
                                          trailing: Consumer<DbProvider>(
                                              builder:
                                                  (context, delete, child) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                              (_) {
                                                if (delete.message != "") {
                                                  if (delete.message.contains(
                                                      "Poll Deleted")) {
                                                    success(context,
                                                        message:
                                                            delete.message);
                                                    polls.fetchUserPolls();
                                                    delete.clear();
                                                  } else {
                                                    error(context,
                                                        message:
                                                            delete.message);
                                                    delete.clear();
                                                  }
                                                }
                                              },
                                            );
                                            return IconButton(
                                                onPressed:
                                                    delete.deleteStatus == true
                                                        ? null
                                                        : () {
                                                            ///
                                                            delete.deletePoll(
                                                                pollId:
                                                                    data.id);
                                                          },
                                                icon: delete.deleteStatus ==
                                                        true
                                                    ? const CircularProgressIndicator()
                                                    : const Icon(Icons.delete));
                                          }),
                                        ),
                                        Text(poll["question"]),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        ...List.generate(options.length,
                                            (index) {
                                          final dataOption = options[index];
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 5),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Stack(

                                                    children: [
                                                      LinearProgressIndicator(
                                                        minHeight: 30,
                                                        value: dataOption[
                                                                "percent"] /
                                                            100,
                                                        backgroundColor:
                                                            AppColors.white,
                                                      ),
                                                      Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 10),
                                                        height: 30,
                                                        child: Text(dataOption[
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
                                          );
                                        }),
                                        Text(
                                            "Total votes : ${poll["total_votes"]}")
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
    );
  }
}
