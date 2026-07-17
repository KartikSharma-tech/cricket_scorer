import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveScoreScreen extends StatefulWidget {
  final Map<String, dynamic> matchData;

  const LiveScoreScreen({super.key, required this.matchData});

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

  int selectedOvers = 0;

  String strikerName = "Batsman 1";
  String nonStrikerName = "Batsman 2";
  String bowlerName = "Bowler";
  String previousBowler = "";

  List<String> bowlingPlayers = [];
  Map<String, Map<String, int>> bowlerStats = {};

  bool lastManBatting = true;

  int totalPlayers = 11;

  List<Map<String, dynamic>> ballHistory = [];

  List<String> outPlayers = [];
  @override
  @override
  void initState() {
    super.initState();

    strikerName = widget.matchData["striker"] ?? "Batsman 1";
    nonStrikerName = widget.matchData["nonStriker"] ?? "Batsman 2";
    bowlerName = widget.matchData["bowler"] ?? "Bowler";
    previousBowler = bowlerName;

    totalPlayers = widget.matchData["players"] ?? 11;
    selectedOvers = widget.matchData["overs"] ?? 5;

    bowlingPlayers = widget.matchData["bowlingPlayers"] != null
        ? List<String>.from(widget.matchData["bowlingPlayers"])
        : [];

    for (String player in bowlingPlayers) {
      bowlerStats[player] = {"runs": 0, "balls": 0, "wickets": 0};
    }
    print("Selected Overs = $selectedOvers");
    print(widget.matchData);
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
      "previousBowler": previousBowler,
      "ballHistory": ballHistory,
    };

    prefs.setString("live_match", jsonEncode(data));
  }

  Future<void> loadMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // // prefs.remove("live_match");
    // return;
    //
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

      strikerName = decoded["strikerName"] ?? strikerName;

      nonStrikerName = decoded["nonStrikerName"] ?? nonStrikerName;

      bowlerName = decoded["bowlerName"] ?? bowlerName;
      previousBowler = decoded["previousBowler"] ?? "";
      ballHistory = List<Map<String, dynamic>>.from(decoded["ballHistory"]);
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

  Future<void> completeBall() async {
    balls++;
    bowlerBalls++;

    bowlerStats[bowlerName]?["balls"] =
        (bowlerStats[bowlerName]?["balls"] ?? 0) + 1;

    if (balls == 6) {
      overs++;
      balls = 0;

      rotateStrike();

      if (overs >= selectedOvers) {
        // Abhi kuch mat likho
        return;
      }

      await selectNextBowler();
    }
  }

  void addBallHistory(String value) {
    ballHistory.insert(0, {"ball": value});
  }

  Future<void> addRuns(int run) async {
    setState(() {
      totalRuns += run;

      strikerRuns += run;
      strikerBalls++;

      bowlerRuns += run;
      bowlerStats[bowlerName]?["runs"] =
          (bowlerStats[bowlerName]?["runs"] ?? 0) + run;

      addBallHistory(run.toString());

      bool changeStrike = run == 1 || run == 3 || run == 5;

      if (changeStrike) {
        rotateStrike();
      }
    });

    await completeBall();

    saveMatch();
  }
  // TODO: Support Wide + Running (WD+1, WD+2, WD+3...) ye fucture meadd krna h

  void addWide() {
    setState(() {
      totalRuns += 1;

      bowlerRuns += 1;
      bowlerStats[bowlerName]?["runs"] =
          (bowlerStats[bowlerName]?["runs"] ?? 0) + 1;
      // addBallHistory("WD");
      addBallHistory("WD1");
    });

    saveMatch();
  }

  void addNoBall(int batRun) {
    setState(() {
      totalRuns += batRun + 1;
      strikerRuns += batRun;

      if (batRun > 0) {
        strikerBalls++;
      }
      bowlerRuns += batRun + 1;
      bowlerStats[bowlerName]?["runs"] =
          (bowlerStats[bowlerName]?["runs"] ?? 0) + (batRun + 1);

      // addBallHistory("NB+$batRun");
      addBallHistory("NB${batRun + 1}");
      // bool changeStrike = batRun == 1 || batRun == 3 || batRun == 5;
      // bool changeStrike = ((batRun + 1) % 2) == 1;
      bool changeStrike = (batRun % 2) == 1;
      if (changeStrike) {
        rotateStrike();
      }
    });

    saveMatch();
  }

  Future<void> addWicket() async {
    if (wickets >= totalPlayers - (lastManBatting ? 1 : 0)) {
      return;
    }

    setState(() {
      addBallHistory("W");

      wickets++;
      outPlayers.add(strikerName);
      bowlerWickets++;
      bowlerStats[bowlerName]?["wickets"] =
          (bowlerStats[bowlerName]?["wickets"] ?? 0) + 1;
      strikerBalls++;

      completeBall();

      if (wickets >= totalPlayers - (lastManBatting ? 1 : 0)) {
        showAllOutDialog();
        Navigator.pop(context);
        return;
      }

      if (lastManBatting && wickets == 9) {
        return;
      }

      // strikerName = "New Batsman";
      // strikerRuns = 0;
      // strikerBalls = 0;
    });
    // await selectNextBatsman();
    await selectNextBatsman(strikerOut: true);
    saveMatch();
  }

  Future<void> selectNextBatsman({required bool strikerOut}) async {
    List<String> availablePlayers = widget.matchData["battingPlayers"] != null
        ? List<String>.from(widget.matchData["battingPlayers"])
        : [];

    availablePlayers.remove(strikerName);
    availablePlayers.remove(nonStrikerName);

    availablePlayers.removeWhere((player) => outPlayers.contains(player));

    if (availablePlayers.isEmpty) {
      return;
    }

    String? selected;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Select Next Batsman",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availablePlayers.length,
              itemBuilder: (context, index) {
                final player = availablePlayers[index];

                return ListTile(
                  title: Text(
                    player,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    selected = player;
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      if (strikerOut) {
        strikerName = selected!;
        strikerRuns = 0;
        strikerBalls = 0;
      } else {
        nonStrikerName = selected!;
        nonStrikerRuns = 0;
        nonStrikerBalls = 0;
      }
    });
  }

  Future<void> selectNextBowler() async {
    List<String> availableBowlers = List<String>.from(bowlingPlayers);

    // Current bowler ko remove karo
    availableBowlers.remove(bowlerName);

    if (availableBowlers.isEmpty) {
      return;
    }

    String? selected;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Select Next Bowler",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableBowlers.length,
              itemBuilder: (context, index) {
                final player = availableBowlers[index];

                return ListTile(
                  title: Text(
                    player,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    selected = player;
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      previousBowler = bowlerName;
      bowlerName = selected!;

      ballHistory.clear();
    });
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
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Innings Finished\nScore : $totalRuns/$wickets",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK", style: TextStyle(color: Colors.black)),
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
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  strikerName,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  selectedPlayer = strikerName;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  nonStrikerName,
                  style: const TextStyle(color: Colors.white),
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
      addBallHistory("RO");

      wickets++;

      completeBall();

      strikerBalls++;

      if (selectedPlayer == strikerName) {
        outPlayers.add(strikerName);
      } else {
        outPlayers.add(nonStrikerName);
      }
    });
    if (selectedPlayer == strikerName) {
      await selectNextBatsman(strikerOut: true);
    } else {
      await selectNextBatsman(strikerOut: false);
    }
    saveMatch();
  }

  void undoBall() {
    if (ballHistory.isEmpty) {
      return;
    }

    setState(() {
      Map<String, dynamic> lastBall = ballHistory.removeAt(0);

      String value = lastBall["ball"];

      if (value.startsWith("WD")) {
        int wideRun = int.parse(value.replaceFirst("WD", ""));

        totalRuns -= wideRun;

        bowlerRuns -= wideRun;
      } else if (value.startsWith("NB")) {
        int batRun = int.parse(value.replaceFirst("NB", "")) - 1;

        totalRuns -= (batRun + 1);

        strikerRuns = (strikerRuns - batRun).clamp(0, 9999);

        strikerBalls = (strikerBalls - 1).clamp(0, 9999);

        bowlerRuns = (bowlerRuns - (batRun + 1)).clamp(0, 9999);
      } else if (value == "W") {
        wickets--;
        if (outPlayers.isNotEmpty) {
          outPlayers.removeLast();
        }
        bowlerWickets = (bowlerWickets - 1).clamp(0, 999);

        strikerBalls = (strikerBalls - 1).clamp(0, 9999);

        if (balls == 0) {
          overs--;
          balls = 5;
        } else {
          balls--;
        }
      } else if (value == "RO") {
        wickets--;
        if (outPlayers.isNotEmpty) {
          outPlayers.removeLast();
        }
        if (balls == 0) {
          overs--;
          balls = 5;
        } else {
          balls--;
        }
      } else {
        int run = int.parse(value);

        totalRuns -= run;

        strikerRuns = (strikerRuns - run).clamp(0, 9999);

        strikerBalls = (strikerBalls - 1).clamp(0, 9999);

        bowlerRuns = (bowlerRuns - run).clamp(0, 9999);

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

  Widget scoreButton(String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (wickets >= totalPlayers - (lastManBatting ? 1 : 0)) {
            return;
          }

          onTap();
        },
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

  Widget batsmanTile(String name, int runs, int balls, bool striker) {
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

  Widget infoCard(String title, String value) {
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
              style: const TextStyle(color: Colors.grey, fontSize: 14),
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
          colors: [Color(0xffFF9800), Color(0xffFF6F00)],
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
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: undoBall,
            icon: const Icon(Icons.undo, color: Colors.orange),
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
                  infoCard("CRR", currentRunRate.toStringAsFixed(2)),
                  infoCard(
                    "Overs",
                    "${((bowlerStats[bowlerName]?["balls"] ?? 0) ~/ 6)}.${((bowlerStats[bowlerName]?["balls"] ?? 0) % 6)}",
                  ),
                ],
              ),

              const SizedBox(height: 20),

              batsmanTile(strikerName, strikerRuns, strikerBalls, true),

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
                            style: TextStyle(color: Colors.grey),
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
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Text(
                          "${bowlerStats[bowlerName]?["wickets"] ?? 0}/${bowlerStats[bowlerName]?["runs"] ?? 0}",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Overs",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Text(
                          "${((bowlerStats[bowlerName]?["balls"] ?? 0) ~/ 6)}.${((bowlerStats[bowlerName]?["balls"] ?? 0) % 6)}",
                          style: const TextStyle(
                            color: Colors.white,
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
                  scoreButton("5", () => addRuns(5)),
                  scoreButton("6", () => addRuns(6)),
                ],
              ),

              Row(
                children: [
                  scoreButton("WD", addWide),
                  scoreButton("NB", () {
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
                                  scoreButton("0", () {
                                    Navigator.pop(context);
                                    addNoBall(0);
                                  }),
                                  scoreButton("1", () {
                                    Navigator.pop(context);
                                    addNoBall(1);
                                  }),
                                  scoreButton("2", () {
                                    Navigator.pop(context);
                                    addNoBall(2);
                                  }),
                                ],
                              ),
                              Row(
                                children: [
                                  scoreButton("4", () {
                                    Navigator.pop(context);
                                    addNoBall(4);
                                  }),
                                  scoreButton("6", () {
                                    Navigator.pop(context);
                                    addNoBall(6);
                                  }),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                  scoreButton("W", addWicket),
                ],
              ),

              Row(
                children: [
                  scoreButton("RO", addRunOut),
                  scoreButton("UNDO", undoBall),
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
