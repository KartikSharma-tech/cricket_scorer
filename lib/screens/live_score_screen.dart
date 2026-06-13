import 'package:flutter/material.dart';
import '../models/player_model.dart';

class LiveScoreScreen extends StatefulWidget {

  final List<PlayerModel> battingPlayers;

  final PlayerModel strikerPlayer;
  final PlayerModel nonStrikerPlayer;
  final PlayerModel bowlerPlayer;

  const LiveScoreScreen({
    super.key,
    required this.battingPlayers,
    required this.strikerPlayer,
    required this.nonStrikerPlayer,
    required this.bowlerPlayer,
  });

  @override
  State<LiveScoreScreen> createState() =>
      _LiveScoreScreenState();
}

class _LiveScoreScreenState
    extends State<LiveScoreScreen> {

  int totalRuns = 0;
  int wickets = 0;

  int over = 0;
  int ball = 0;

  late PlayerModel striker;
  late PlayerModel nonStriker;
  late PlayerModel currentBowler;

  int nextBatsmanIndex = 0;

  bool isMatchEnded = false;

  @override
  void initState() {

    super.initState();

    striker =
    widget.strikerPlayer;

    nonStriker =
    widget.nonStrikerPlayer;

    currentBowler =
    widget.bowlerPlayer;

    nextBatsmanIndex = 0;

    for(int i = 0;
    i < widget.battingPlayers.length;
    i++){

      PlayerModel player =
      widget.battingPlayers[i];

      if(player != striker &&
          player != nonStriker){

        nextBatsmanIndex = i;
        break;
      }
    }
  }

  void swapStrike(){

    PlayerModel temp = striker;

    striker = nonStriker;
    nonStriker = temp;
  }

  void addRun(int run){

    if(isMatchEnded) return;

    setState(() {

      totalRuns += run;

      striker.runs += run;
      striker.balls++;

      currentBowler.runsGiven += run;
      currentBowler.ballsBowled++;

      ball++;

      // STRIKE ROTATE

      if(run == 1 || run == 3){

        swapStrike();
      }

      // OVER COMPLETE

      if(ball == 6){

        over++;
        ball = 0;

        swapStrike();

        showBowlerDialog();
      }
    });
  }

  void addWide(){

    if(isMatchEnded) return;

    setState(() {

      totalRuns += 1;

      currentBowler.runsGiven += 1;
    });
  }

  void addNoBall(){

    if(isMatchEnded) return;

    setState(() {

      totalRuns += 1;

      currentBowler.runsGiven += 1;
    });
  }

  void addWicket(){

    if(isMatchEnded) return;

    setState(() {

      wickets++;

      striker.balls++;

      currentBowler.ballsBowled++;

      ball++;

      int wicketsLimit =
          widget.battingPlayers.length - 1;

      // ALL OUT

      if(wickets >= wicketsLimit){

        isMatchEnded = true;

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text("All Out"),
          ),
        );

        return;
      }

      showNewBatsmanDialog();

      // OVER COMPLETE

      if(ball == 6){

        over++;
        ball = 0;

        swapStrike();

        showBowlerDialog();
      }
    });
  }

  double getStrikeRate(
      PlayerModel player){

    if(player.balls == 0){
      return 0;
    }

    return
        (player.runs / player.balls) * 100;
  }

  double getEconomy(){

    double oversBowled =
        currentBowler.ballsBowled / 6;

    if(oversBowled == 0){
      return 0;
    }

    return
        currentBowler.runsGiven /
            oversBowled;
  }

  double getCurrentRunRate(){

    double currentOvers =
        over + (ball / 6);

    if(currentOvers == 0){
      return 0;
    }

    return totalRuns / currentOvers;
  }

  void showNewBatsmanDialog(){

    List<PlayerModel> remainingPlayers =
    widget.battingPlayers.where((player){

      return player != striker &&
          player != nonStriker;

    }).toList();

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context){

        return AlertDialog(

          title: const Text(
            "Select New Batsman",
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children:
            remainingPlayers.map((player){

              return ListTile(

                title: Text(player.name),

                onTap: (){

                  setState(() {

                    striker = player;
                  });

                  Navigator.pop(context);
                },
              );

            }).toList(),
          ),
        );
      },
    );
  }

  void showBowlerDialog(){

    showDialog(

      context: context,

      builder: (context){

        return AlertDialog(

          title: const Text(
            "Over Complete",
          ),

          content: const Text(
            "Select Next Bowler Later",
          ),

          actions: [

            TextButton(

              onPressed: (){

                Navigator.pop(context);
              },

              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget runButton(
      String text,
      VoidCallback onTap){

    return SizedBox(
      width: 80,
      height: 60,

      child: ElevatedButton(

        style:
        ElevatedButton.styleFrom(

          backgroundColor:
          const Color(0xff1E293B),
        ),

        onPressed: onTap,

        child: Text(
          text,

          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Live Score"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(

          child: Column(
            children: [

              // SCORE CARD

              Container(
                width: double.infinity,

                padding:
                const EdgeInsets.all(25),

                decoration: BoxDecoration(

                  color:
                  const Color(0xff1E293B),

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Column(
                  children: [

                    Text(
                      "$totalRuns/$wickets",

                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Overs: $over.$ball",

                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "CRR: ${getCurrentRunRate().toStringAsFixed(2)}",

                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.orange,
                      ),
                    ),

                    if(isMatchEnded)

                      const Padding(
                        padding:
                        EdgeInsets.only(top: 10),

                        child: Text(
                          "INNINGS ENDED",

                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // BATSMEN

              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color:
                  const Color(0xff1E293B),

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Batsmen",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // STRIKER

                    Text(
                      "${striker.name} 🏏",

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Runs: ${striker.runs}",
                    ),

                    Text(
                      "Balls: ${striker.balls}",
                    ),

                    Text(
                      "SR: ${getStrikeRate(striker).toStringAsFixed(1)}",
                    ),

                    const SizedBox(height: 25),

                    // NON STRIKER

                    Text(
                      nonStriker.name,

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Runs: ${nonStriker.runs}",
                    ),

                    Text(
                      "Balls: ${nonStriker.balls}",
                    ),

                    Text(
                      "SR: ${getStrikeRate(nonStriker).toStringAsFixed(1)}",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // BOWLER

              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color:
                  const Color(0xff1E293B),

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Current Bowler",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      currentBowler.name,

                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.cyan,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Runs Given: ${currentBowler.runsGiven}",
                    ),

                    Text(
                      "Balls: ${currentBowler.ballsBowled}",
                    ),

                    Text(
                      "Economy: ${getEconomy().toStringAsFixed(2)}",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BUTTONS

              Wrap(

                spacing: 12,
                runSpacing: 12,

                children: [

                  runButton("0", (){
                    addRun(0);
                  }),

                  runButton("1", (){
                    addRun(1);
                  }),

                  runButton("2", (){
                    addRun(2);
                  }),

                  runButton("3", (){
                    addRun(3);
                  }),

                  runButton("4", (){
                    addRun(4);
                  }),

                  runButton("6", (){
                    addRun(6);
                  }),

                  runButton("W", (){
                    addWicket();
                  }),

                  runButton("WD", (){
                    addWide();
                  }),

                  runButton("NB", (){
                    addNoBall();
                  }),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}