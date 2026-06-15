import 'package:flutter/material.dart';

import '../models/player_model.dart';

class LiveScoreScreen extends StatefulWidget {

  final List<PlayerModel> battingPlayers;

  final List<PlayerModel> bowlingPlayers;

  final PlayerModel strikerPlayer;

  final PlayerModel nonStrikerPlayer;

  final PlayerModel bowlerPlayer;

  const LiveScoreScreen({
    super.key,
    required this.battingPlayers,
    required this.bowlingPlayers,
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

  bool isMatchEnded = false;

  late PlayerModel striker;

  late PlayerModel nonStriker;

  late PlayerModel currentBowler;

  @override
  void initState() {

    super.initState();

    striker =
    widget.strikerPlayer;

    nonStriker =
    widget.nonStrikerPlayer;

    currentBowler =
    widget.bowlerPlayer;
  }

  // =========================
  // RUN RATE
  // =========================

  double getRunRate(){

    double overs =
        over + (ball / 6);

    if(overs == 0){
      return 0;
    }

    return totalRuns / overs;
  }

  // =========================
  // ECONOMY
  // =========================

  double getEconomy(){

    double oversBowled =
        currentBowler.ballsBowled / 6;

    if(oversBowled == 0){
      return 0;
    }

    return currentBowler.runsGiven /
        oversBowled;
  }

  // =========================
  // STRIKE RATE
  // =========================

  double getStrikeRate(){

    if(striker.balls == 0){
      return 0;
    }

    return
        (striker.runs / striker.balls)
        * 100;
  }

  // =========================
  // CHANGE STRIKE
  // =========================

  void swapStrike(){

    PlayerModel temp = striker;

    striker = nonStriker;

    nonStriker = temp;
  }

  // =========================
  // ADD RUN
  // =========================

  void addRun(int run){

    if(isMatchEnded){
      return;
    }

    setState(() {

      totalRuns += run;

      striker.runs += run;

      striker.balls++;

      currentBowler.runsGiven += run;

      currentBowler.ballsBowled++;

      ball++;

      // STRIKE CHANGE

      if(run == 1 ||
          run == 3 ||
          run == 5){

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

  // =========================
  // WIDE
  // =========================

  void addWide(){

    if(isMatchEnded){
      return;
    }

    setState(() {

      totalRuns++;

      currentBowler.runsGiven++;
    });
  }

  // =========================
  // NO BALL
  // =========================

  void addNoBall(){

    if(isMatchEnded){
      return;
    }

    setState(() {

      totalRuns++;

      currentBowler.runsGiven++;
    });
  }

  // =========================
  // WICKET
  // =========================

void addWicket(){

  if(isMatchEnded){

    return;
  }

  setState(() {

    wickets++;

    striker.balls++;

    currentBowler.ballsBowled++;

    currentBowler.wickets++;

    ball++;

    // OUT PLAYER ADD

    outPlayers.add(striker);

    // ALL OUT

    if(

    wickets >=
    widget.battingPlayers.length

    ){

      isMatchEnded = true;

      showAllOutDialog();

      return;
    }

    // REMAINING PLAYERS

    List<PlayerModel>
    remainingPlayers =

    widget.battingPlayers.where((player){

      return

      !outPlayers.contains(player)

          &&

          player != nonStriker;

    }).toList();

    // NEW BATSMAN

    if(remainingPlayers.isNotEmpty){

      showNewBatsmanDialog(
          remainingPlayers);

    }else{

      // SOLO PLAYER

      striker = nonStriker;
    }

    // OVER COMPLETE

    if(ball == 6){

      over++;

      ball = 0;

      bool soloPlayer =

          wickets >=
          widget.battingPlayers.length - 1;

      if(!soloPlayer){

        swapStrike();
      }

      showBowlerDialog();
    }
  });
}



    if(isMatchEnded){
      return;
    }

    setState(() {

      wickets++;

      striker.balls++;

      currentBowler.ballsBowled++;

      ball++;

      // ALL OUT

      if(wickets >=
          widget.battingPlayers.length){

        isMatchEnded = true;

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text("All Out"),
          ),
        );

        return;
      }

      // OVER COMPLETE

      if(ball == 6){

        over++;

        ball = 0;

        swapStrike();

        showBowlerDialog();
      }
    });

    List<PlayerModel> remainingPlayers =

    widget.battingPlayers.where((player){

      return player != striker &&
          player != nonStriker;

    }).toList();

    // NEW BATSMAN

    if(remainingPlayers.isNotEmpty){

      showNewBatsmanDialog();
    }
  }

  // =========================
  // NEW BATSMAN
  // =========================

  void showNewBatsmanDialog(){

    List<PlayerModel> availablePlayers =

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

          content: SizedBox(

            width: double.maxFinite,

            child: ListView.builder(

              shrinkWrap: true,

              itemCount:
              availablePlayers.length,

              itemBuilder: (context, index){

                PlayerModel player =
                availablePlayers[index];

                return ListTile(

                  title: Text(
                    player.name,
                  ),

                  onTap: (){

                    setState(() {

                      striker = player;
                    });

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // =========================
  // NEXT BOWLER
  // =========================

  void showBowlerDialog(){

    List<PlayerModel> availableBowlers =

    widget.bowlingPlayers.where((player){

      return player != currentBowler;

    }).toList();

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context){

        return AlertDialog(

          title: const Text(
            "Select Next Bowler",
          ),

          content: SizedBox(

            width: double.maxFinite,

            child: ListView.builder(

              shrinkWrap: true,

              itemCount:
              availableBowlers.length,

              itemBuilder: (context, index){

                PlayerModel bowler =
                availableBowlers[index];

                return ListTile(

                  title: Text(
                    bowler.name,
                  ),

                  onTap: (){

                    setState(() {

                      currentBowler =
                      bowler;
                    });

                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // =========================
  // BUTTON
  // =========================

  Widget runButton(
      String text,
      VoidCallback onTap){

    return SizedBox(

      width: 80,
      height: 60,

      child: ElevatedButton(

        style: ElevatedButton.styleFrom(

          backgroundColor:
          const Color(0xff1E293B),
        ),

        onPressed: onTap,

        child: Text(

          text,

          style: const TextStyle(
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
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

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          children: [

            // SCORE

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

                      fontSize: 42,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(

                    "Overs: $over.$ball",

                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(

                    "CRR: ${getRunRate().toStringAsFixed(2)}",

                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // BATSMAN

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

                    "Striker",

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    striker.name,
                  ),

                  Text(
                    "Runs: ${striker.runs}",
                  ),

                  Text(
                    "Balls: ${striker.balls}",
                  ),

                  Text(
                    "SR: ${getStrikeRate().toStringAsFixed(1)}",
                  ),

                  const SizedBox(height: 20),

                  const Text(

                    "Non Striker",

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(nonStriker.name),

                  Text(
                    "Runs: ${nonStriker.runs}",
                  ),

                  Text(
                    "Balls: ${nonStriker.balls}",
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

                    "Bowler",

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    currentBowler.name,
                  ),

                  Text(
                    "Runs Given: ${currentBowler.runsGiven}",
                  ),

                  Text(
                    "Balls: ${currentBowler.ballsBowled}",
                  ),

                  Text(
                    "Economy: ${getEconomy().toStringAsFixed(1)}",
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}