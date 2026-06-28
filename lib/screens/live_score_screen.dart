import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveScoreScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;

  const LiveScoreScreen({
    super.key,
    required this.matchData,
  });

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen> {
  int totalRuns = 0;
  int wickets = 0;

  int overs = 0;
  int balls = 0;

  int strikerRuns = 0;
  int strikerBalls = 0;

  int nonStrikerRuns = 0;
  int nonStrikerBalls = 0;

  int bowlerRuns = 0;
  int bowlerWickets = 0;
  int bowlerBalls = 0;

  String strikerName = "Batsman 1";
  String nonStrikerName = "Batsman 2";
  String bowlerName = "Bowler";

  bool lastManBatting = true;

  List<Map<String, dynamic>> ballHistory = [];

  @override
  void initState() {
    super.initState();

    strikerName = widget.matchData["striker"] ?? "Batsman 1";
    nonStrikerName = widget.matchData["nonStriker"] ?? "Batsman 2";
    bowlerName = widget.matchData["bowler"] ?? "Bowler";

    loadMatch();
  }

  double get currentRunRate {
    double totalOvers = overs + (balls / 6);

    if (totalOvers == 0) {
      return 0.0;
    }

    return totalRuns / totalOvers;
  }

  String get overText {
    return "$overs.$balls";
  }

  Future<void> saveMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> data = {
      "totalRuns": totalRuns,
      "wickets": wickets,
      "overs": overs,
      "balls": balls,
      "strikerRuns": strikerRuns,
      "strikerBalls": strikerBalls,
      "nonStrikerRuns": nonStrikerRuns,
      "nonStrikerBalls": nonStrikerBalls,
      "bowlerRuns": bowlerRuns,
      "bowlerWickets": bowlerWickets,
      "bowlerBalls": bowlerBalls,
      "strikerName": strikerName,
      "nonStrikerName": nonStrikerName,
      "bowlerName": bowlerName,
      "ballHistory": ballHistory,
    };

    prefs.setString(
      "live_match",
      jsonEncode(data),
    );
  }

  Future<void> loadMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? data = prefs.getString("live_match");

    if (data == null) {
      return;
    }

    Map<String, dynamic> decoded = jsonDecode(data);

    setState(() {
      totalRuns = decoded["totalRuns"];
      wickets = decoded["wickets"];

      overs = decoded["overs"];
      balls = decoded["balls"];

      strikerRuns = decoded["strikerRuns"];
      strikerBalls = decoded["strikerBalls"];

      nonStrikerRuns = decoded["nonStrikerRuns"];
      nonStrikerBalls = decoded["nonStrikerBalls"];

      bowlerRuns = decoded["bowlerRuns"];
      bowlerWickets = decoded["bowlerWickets"];
      bowlerBalls = decoded["bowlerBalls"];

      strikerName = decoded["strikerName"];
      nonStrikerName = decoded["nonStrikerName"];
      bowlerName = decoded["bowlerName"];

      ballHistory = List<Map<String, dynamic>>.from(
        decoded["ballHistory"],
      );
    });
  }

  void rotateStrike() {
    String tempName = strikerName;
    strikerName = nonStrikerName;
    nonStrikerName = tempName;

    int tempRuns = strikerRuns;
    strikerRuns = nonStrikerRuns;
    nonStrikerRuns = tempRuns;

    int tempBalls = strikerBalls;
    strikerBalls = nonStrikerBalls;
    nonStrikerBalls = tempBalls;
  }

  void completeBall() {
    balls++;
    bowlerBalls++;

    if (balls == 6) {
      overs++;
      balls = 0;

      rotateStrike();
    }
  }

  void addBallHistory(
    String value,
  ) {
    ballHistory.insert(
      0,
      {
        "ball": value,
      },
    );
  }

  void addRuns(
    int run,
  ) {
    setState(() {
      totalRuns += run;

      strikerRuns += run;
      strikerBalls++;

      bowlerRuns += run;

      addBallHistory(run.toString());

      completeBall();

      if (run == 1 || run == 3 || run == 5) {
        rotateStrike();
      }
    });

    saveMatch();
  }

  void addWide() {
    setState(() {
      totalRuns += 1;

      bowlerRuns += 1;

      addBallHistory("WD");
    });

    saveMatch();
  }

  void addNoBall(
    int batRun,
  ) {
    setState(() {
      totalRuns += batRun + 1;

      strikerRuns += batRun;
      strikerBalls++;

      bowlerRuns += batRun + 1;

      addBallHistory("NB+$batRun");

      if (batRun == 1 || batRun == 3 || batRun == 5) {
        rotateStrike();
      }
    });

    saveMatch();
  }

  void addWicket() {
  if (wickets >= 10) {
    return;
  }

  setState(() {
    wickets++;

    bowlerWickets++;

    strikerBalls++;

    addBallHistory("W");

    completeBall();

    if (wickets >= 10) {
      showAllOutDialog();
      return;
    }

    if (lastManBatting && wickets == 9) {
      return;
    }

    strikerName = "New Batsman";
    strikerRuns = 0;
    strikerBalls = 0;
  });

  saveMatch();
}
void showAllOutDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "All Out",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Innings Finished\nScore : $totalRuns/$wickets",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "OK",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      );
    },
  );
}
  void addRunOut() async {
    String? selectedPlayer;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Select Out Batsman",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  strikerName,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  selectedPlayer = strikerName;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  nonStrikerName,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  selectedPlayer = nonStrikerName;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedPlayer == null) {
      return;
    }

    setState(() {
      wickets++;

      addBallHistory("RO");

      completeBall();

      if (selectedPlayer == strikerName) {
        strikerBalls++;

        strikerName = "New Batsman";
        strikerRuns = 0;
        strikerBalls = 0;
      } else {
        nonStrikerName = "New Batsman";
        nonStrikerRuns = 0;
        nonStrikerBalls = 0;
      }
    });

    saveMatch();
  }

  void undoBall() {
  if (ballHistory.isEmpty) {
    return;
  }

  setState(() {
    Map<String, dynamic> lastBall = ballHistory.removeAt(0);

    String value = lastBall["ball"];

    if (value == "WD") {
      totalRuns -= 1;
      bowlerRuns -= 1;
    } else if (value.startsWith("NB")) {
      List parts = value.split("+");

      int batRun = int.parse(parts[1]);

      totalRuns -= (batRun + 1);

      strikerRuns -= batRun;
      strikerBalls -= 1;

      bowlerRuns -= (batRun + 1);
    } else if (value == "W") {
      wickets--;

      bowlerWickets--;

      strikerBalls--;

      if (balls == 0) {
        overs--;
        balls = 5;
      } else {
        balls--;
      }
    } else if (value == "RO") {
      wickets--;

      if (balls == 0) {
        overs--;
        balls = 5;
      } else {
        balls--;
      }
    } else {
      int run = int.parse(value);

      totalRuns -= run;

      strikerRuns -= run;
      strikerBalls--;

      bowlerRuns -= run;

      if (balls == 0) {
        overs--;
        balls = 5;
      } else {
        balls--;
      }

      if (run == 1 || run == 3 || run == 5) {
        rotateStrike();
      }
    }
  });

  saveMatch();
}

  Widget scoreButton(
    String text,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget batsmanTile(
    String name,
    int runs,
    int balls,
    bool striker,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xff1A1A1A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (striker)
                  const Text(
                    "* ",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$runs ($balls)",
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard(
    String title,
    String value,
  ) {
    return Expanded(
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xff1A1A1A),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recentBalls() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        reverse: true,
        scrollDirection: Axis.horizontal,
        itemCount: ballHistory.length,
        itemBuilder: (context, index) {
          return Container(
            width: 45,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                ballHistory[index]["ball"],
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget topScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffFF9800),
            Color(0xffFF6F00),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            "LIVE SCORE",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "$totalRuns/$wickets",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 52,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Overs $overText",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Cricket Scorer",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: undoBall,
            icon: const Icon(
              Icons.undo,
              color: Colors.orange,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              topScoreCard(),

              const SizedBox(height: 18),

              Row(
                children: [
                  infoCard(
                    "CRR",
                    currentRunRate.toStringAsFixed(2),
                  ),
                  infoCard(
                    "Bowler",
                    bowlerName,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              batsmanTile(
                strikerName,
                strikerRuns,
                strikerBalls,
                true,
              ),

              batsmanTile(
                nonStrikerName,
                nonStrikerRuns,
                nonStrikerBalls,
                false,
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xff1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Bowler",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          bowlerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Figures",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          "$bowlerWickets/$bowlerRuns",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              recentBalls(),

              const SizedBox(height: 18),

              Row(
                children: [
                  scoreButton("0", () => addRuns(0)),
                  scoreButton("1", () => addRuns(1)),
                  scoreButton("2", () => addRuns(2)),
                ],
              ),

              Row(
                children: [
                  scoreButton("3", () => addRuns(3)),
                  scoreButton("4", () => addRuns(4)),
                  scoreButton("6", () => addRuns(6)),
                ],
              ),

              Row(
                children: [
                  scoreButton("WD", addWide),
                  scoreButton(
                    "NB",
                    () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.black,
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "No Ball Runs",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    scoreButton(
                                      "0",
                                      () {
                                        Navigator.pop(context);
                                        addNoBall(0);
                                      },
                                    ),
                                    scoreButton(
                                      "1",
                                      () {
                                        Navigator.pop(context);
                                        addNoBall(1);
                                      },
                                    ),
                                    scoreButton(
                                      "2",
                                      () {
                                        Navigator.pop(context);
                                        addNoBall(2);
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    scoreButton(
                                      "4",
                                      () {
                                        Navigator.pop(context);
                                        addNoBall(4);
                                      },
                                    ),
                                    scoreButton(
                                      "6",
                                      () {
                                        Navigator.pop(context);
                                        addNoBall(6);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  scoreButton("W", addWicket),
                ],
              ),

              Row(
                children: [
                  scoreButton(
                    "RO",
                    addRunOut,
                  ),
                  scoreButton(
                    "UNDO",
                    undoBall,
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}