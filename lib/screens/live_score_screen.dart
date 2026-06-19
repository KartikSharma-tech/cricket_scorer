// ```dart
import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/match_service.dart';
import '../services/match_storage_service.dart';

class LiveScoreScreen extends StatefulWidget {

  const LiveScoreScreen({
    super.key,
  });

  @override
  State<LiveScoreScreen> createState() =>
      _LiveScoreScreenState();
}

class _LiveScoreScreenState
    extends State<LiveScoreScreen> {

  // =========================
  // GETTERS
  // =========================

  PlayerModel get striker =>
      MatchService.striker!;

  PlayerModel get nonStriker =>
      MatchService.nonStriker!;

  PlayerModel get currentBowler =>
      MatchService.currentBowler!;

  // =========================
  // SWAP STRIKE
  // =========================

  void swapStrike(){

    PlayerModel temp =
    MatchService.striker!;

    MatchService.striker =
        MatchService.nonStriker;

    MatchService.nonStriker =
        temp;
  }

  // =========================
  // CHECK RESULT
  // =========================

  void checkMatchResult(){

    MatchService.checkWinner();

    if(MatchService.isMatchEnded){

      showInningsCompleteDialog();
    }
  }

  // =========================
  // COMPLETE OVER
  // =========================

  void completeOver(){

    MatchService.over++;

    MatchService.ball = 0;

    bool soloPlayer =

        MatchService.wickets >=

            MatchService
                .battingPlayers
                .length - 2;

    if(!soloPlayer){

      swapStrike();
    }

    // MATCH END

    if(

    MatchService.over >=
        MatchService.totalOvers

    ){

      if(

      MatchService.isSecondInnings

      ){

        checkMatchResult();

      }else{

        showInningsCompleteDialog();
      }

      return;
    }

    showBowlerDialog();
  }

  // =========================
  // ADD RUN
  // =========================

  void addRun(int run){

    if(MatchService.isMatchEnded){
      return;
    }

    setState(() {

      MatchService.totalRuns += run;

      striker.runs += run;

      striker.balls++;

      currentBowler.runsGiven += run;

      currentBowler.ballsBowled++;

      MatchService.ball++;

      bool soloPlayer =

          MatchService.wickets >=

              MatchService
                  .battingPlayers
                  .length - 2;

      // STRIKE ROTATE

      if(

      !soloPlayer &&

          (run == 1 ||
              run == 3 ||
              run == 5)

      ){

        swapStrike();
      }

      // OVER COMPLETE

      if(MatchService.ball == 6){

        completeOver();
      }

      // RESULT CHECK

      if(MatchService.isSecondInnings){

        checkMatchResult();
      }

      MatchStorageService
          .saveMatch();
    });
  }

  // =========================
  // WIDE
  // =========================

  void addWide(){

    if(MatchService.isMatchEnded){
      return;
    }

    setState(() {

      MatchService.totalRuns++;

      MatchService.wides++;

      currentBowler.runsGiven++;

      if(MatchService.isSecondInnings){

        checkMatchResult();
      }

      MatchStorageService
          .saveMatch();
    });
  }

  // =========================
  // NO BALL
  // =========================

  void addNoBall(){

    if(MatchService.isMatchEnded){
      return;
    }

    setState(() {

      MatchService.totalRuns++;

      MatchService.noBalls++;

      currentBowler.runsGiven++;

      if(MatchService.isSecondInnings){

        checkMatchResult();
      }

      MatchStorageService
          .saveMatch();
    });
  }

  // =========================
  // NORMAL WICKET
  // =========================

  void addWicket(){

    if(MatchService.isMatchEnded){
      return;
    }

    setState(() {

      MatchService.wickets++;

      striker.balls++;

      currentBowler.wickets++;

      currentBowler.ballsBowled++;

      MatchService.ball++;

      MatchService.outPlayers
          .add(striker);

      // ALL OUT

      if(

      MatchService.wickets >=

          MatchService
              .battingPlayers
              .length - 1

      ){

        if(

        MatchService.isSecondInnings

        ){

          checkMatchResult();

        }else{

          showInningsCompleteDialog();
        }

        return;
      }

      List<PlayerModel>
      remainingPlayers =

      MatchService.battingPlayers
          .where((player){

        return

        !MatchService.outPlayers
            .contains(player)

            &&

            player != nonStriker;

      }).toList();

      if(remainingPlayers.isNotEmpty){

        showNewBatsmanDialog(
          remainingPlayers,
        );
      }

      if(MatchService.ball == 6){

        completeOver();
      }

      MatchStorageService
          .saveMatch();
    });
  }

  // =========================
  // RUN OUT
  // =========================

  void addRunOut(){

    if(MatchService.isMatchEnded){
      return;
    }

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context){

        return AlertDialog(

          title: const Text(
            "Select Out Batsman",
          ),

          content: Column(

            mainAxisSize:
            MainAxisSize.min,

            children: [

              ListTile(

                title:
                Text(striker.name),

                subtitle:
                const Text(
                  "Striker",
                ),

                onTap: (){

                  Navigator.pop(context);

                  processRunOut(
                    striker,
                  );
                },
              ),

              ListTile(

                title:
                Text(nonStriker.name),

                subtitle:
                const Text(
                  "Non Striker",
                ),

                onTap: (){

                  Navigator.pop(context);

                  processRunOut(
                    nonStriker,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================
  // PROCESS RUN OUT
  // =========================

  void processRunOut(
      PlayerModel outPlayer,
      ){

    setState(() {

      MatchService.wickets++;

      outPlayer.balls++;

      MatchService.ball++;

      MatchService.outPlayers
          .add(outPlayer);

      // ALL OUT

      if(

      MatchService.wickets >=

          MatchService
              .battingPlayers
              .length - 1

      ){

        if(

        MatchService.isSecondInnings

        ){

          checkMatchResult();

        }else{

          showInningsCompleteDialog();
        }

        return;
      }

      List<PlayerModel>
      remainingPlayers =

      MatchService.battingPlayers
          .where((player){

        return

        !MatchService.outPlayers
            .contains(player)

            &&

            player != striker

            &&

            player != nonStriker;

      }).toList();

      if(remainingPlayers.isNotEmpty){

        showRunOutBatsmanDialog(

          remainingPlayers,

          outPlayer,
        );
      }

      if(MatchService.ball == 6){

        completeOver();
      }

      MatchStorageService
          .saveMatch();
    });
  }

  // =========================
  // NEW BATSMAN
  // =========================

  void showNewBatsmanDialog(
      List<PlayerModel> players){

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
              players.length,

              itemBuilder:
                  (context, index){

                PlayerModel player =
                players[index];

                return ListTile(

                  title:
                  Text(player.name),

                  onTap: (){

                    setState(() {

                      MatchService.striker =
                          player;
                    });

                    MatchStorageService
                        .saveMatch();

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
  // RUN OUT NEW BATSMAN
  // =========================

  void showRunOutBatsmanDialog(

      List<PlayerModel> players,

      PlayerModel outPlayer,

      ){

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
              players.length,

              itemBuilder:
                  (context, index){

                PlayerModel player =
                players[index];

                return ListTile(

                  title:
                  Text(player.name),

                  onTap: (){

                    setState(() {

                      if(outPlayer ==
                          striker){

                        MatchService.striker =
                            player;

                      }else{

                        MatchService.nonStriker =
                            player;
                      }
                    });

                    MatchStorageService
                        .saveMatch();

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
  // BOWLER DIALOG
  // =========================

  void showBowlerDialog(){

    List<PlayerModel>
    bowlers =

    MatchService.bowlingPlayers
        .where((player){

      return player !=
          currentBowler;

    }).toList();

    if(bowlers.isEmpty){
      return;
    }

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
              bowlers.length,

              itemBuilder:
                  (context, index){

                PlayerModel bowler =
                bowlers[index];

                return ListTile(

                  title:
                  Text(bowler.name),

                  onTap: (){

                    setState(() {

                      MatchService
                          .currentBowler =
                          bowler;
                    });

                    MatchStorageService
                        .saveMatch();

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
  // STRIKE RATE
  // =========================

  double getStrikeRate(
      PlayerModel player){

    if(player.balls == 0){
      return 0;
    }

    return

        (player.runs / player.balls)
            * 100;
  }

  // =========================
  // BOWLER OVERS
  // =========================

  String getBowlerOvers(){

    int overs =

        currentBowler
            .ballsBowled ~/ 6;

    int balls =

        currentBowler
            .ballsBowled % 6;

    return "$overs.$balls";
  }

  // =========================
  // ECONOMY
  // =========================

  double getEconomy(){

    if(currentBowler
        .ballsBowled == 0){

      return 0;
    }

    double overs =

        currentBowler
            .ballsBowled / 6;

    return

        currentBowler.runsGiven
            / overs;
  }

  // =========================
  // STAT BOX
  // =========================

  Widget statBox(
      String title,
      String value,
      ){

    return Column(

      children: [

        Text(

          title,

          style: const TextStyle(

            color: Colors.white70,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        Text(

          value,

          style: const TextStyle(

            fontSize: 18,

            fontWeight:
            FontWeight.bold,

            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // =========================
  // PLAYER CARD
  // =========================

  Widget playerCard({

    required String title,

    required PlayerModel player,

    bool isStriker = false,

  }){

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color:
        const Color(
          0xff1E293B,
        ),

        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style: const TextStyle(

              fontSize: 18,

              fontWeight:
              FontWeight.bold,

              color: Colors.orange,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Row(

            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

            children: [

              Expanded(

                child: Text(

                  isStriker

                      ?

                  "${player.name} *"

                      :

                  player.name,

                  style: const TextStyle(

                    fontSize: 24,

                    fontWeight:
                    FontWeight.bold,

                    color: Colors.white,
                  ),
                ),
              ),

              Text(

                "${player.runs}"
                    " (${player.balls})",

                style: const TextStyle(

                  fontSize: 22,

                  fontWeight:
                  FontWeight.bold,

                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Text(

            "Strike Rate : "
                "${getStrikeRate(player).toStringAsFixed(1)}",

            style: const TextStyle(

              color: Colors.white70,

              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // BOWLER CARD
  // =========================

  Widget bowlerCard(){

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color:
        const Color(
          0xff1E293B,
        ),

        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Text(

            "Current Bowler",

            style: TextStyle(

              fontSize: 18,

              fontWeight:
              FontWeight.bold,

              color: Colors.orange,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Row(

            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

            children: [

              Expanded(

                child: Text(

                  currentBowler.name,

                  style: const TextStyle(

                    fontSize: 24,

                    fontWeight:
                    FontWeight.bold,

                    color: Colors.white,
                  ),
                ),
              ),

              Text(

                "${currentBowler.wickets}"
                    "/"
                    "${currentBowler.runsGiven}",

                style: const TextStyle(

                  fontSize: 22,

                  fontWeight:
                  FontWeight.bold,

                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Text(

            "Overs : "
                "${getBowlerOvers()}",

            style: const TextStyle(

              color: Colors.white70,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(

            "Economy : "
                "${getEconomy().toStringAsFixed(2)}",

            style: const TextStyle(

              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SECOND INNINGS
  // =========================

  void startSecondInnings(){

    Navigator.pop(context);

    MatchService.firstInningsScore =
        MatchService.totalRuns;

    MatchService.target =
        MatchService.firstInningsScore + 1;

    MatchService.isSecondInnings =
    true;

    List<PlayerModel>
    oldBatting =

        MatchService.battingPlayers;

    MatchService.battingPlayers =

        MatchService.bowlingPlayers;

    MatchService.bowlingPlayers =
        oldBatting;

    MatchService.resetInnings();

    showSecondInningsSetup();
  }

  // =========================
  // SECOND INNINGS SETUP
  // =========================

  void showSecondInningsSetup(){

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context){

        PlayerModel?
        selectedStriker;

        PlayerModel?
        selectedNonStriker;

        PlayerModel?
        selectedBowler;

        return StatefulBuilder(

          builder: (context, setDialogState){

            return AlertDialog(

              title: const Text(
                "2nd Innings Setup",
              ),

              content:
              SingleChildScrollView(

                child: Column(

                  children: [

                    DropdownButton<
                        PlayerModel>(

                      isExpanded: true,

                      hint: const Text(
                        "Select Striker",
                      ),

                      value:
                      selectedStriker,

                      items:

                      MatchService
                          .battingPlayers
                          .map((player){

                        return DropdownMenuItem(

                          value: player,

                          child:
                          Text(player.name),
                        );

                      }).toList(),

                      onChanged: (value){

                        setDialogState(() {

                          selectedStriker =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    DropdownButton<
                        PlayerModel>(

                      isExpanded: true,

                      hint: const Text(
                        "Select Non Striker",
                      ),

                      value:
                      selectedNonStriker,

                      items:

                      MatchService
                          .battingPlayers
                          .where((player){

                        return player !=
                            selectedStriker;

                      }).map((player){

                        return DropdownMenuItem(

                          value: player,

                          child:
                          Text(player.name),
                        );

                      }).toList(),

                      onChanged: (value){

                        setDialogState(() {

                          selectedNonStriker =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    DropdownButton<
                        PlayerModel>(

                      isExpanded: true,

                      hint: const Text(
                        "Select Bowler",
                      ),

                      value:
                      selectedBowler,

                      items:

                      MatchService
                          .bowlingPlayers
                          .map((player){

                        return DropdownMenuItem(

                          value: player,

                          child:
                          Text(player.name),
                        );

                      }).toList(),

                      onChanged: (value){

                        setDialogState(() {

                          selectedBowler =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [

                TextButton(

                  onPressed: (){

                    if(

                    selectedStriker ==
                        null ||

                        selectedNonStriker ==
                            null ||

                        selectedBowler ==
                            null

                    ){

                      return;
                    }

                    setState(() {

                      MatchService.striker =
                          selectedStriker;

                      MatchService.nonStriker =
                          selectedNonStriker;

                      MatchService.currentBowler =
                          selectedBowler;
                    });

                    MatchStorageService
                        .saveMatch();

                    Navigator.pop(context);
                  },

                  child: const Text(
                    "Start Innings",
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================
  // COMPLETE DIALOG
  // =========================

  void showInningsCompleteDialog(){

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context){

        return AlertDialog(

          title: Text(

            MatchService.isSecondInnings

                ?

            "Match Finished"

                :

            "1st Innings Complete",
          ),

          content: Column(

            mainAxisSize:
            MainAxisSize.min,

            children: [

              Text(

                "Score : "

                    "${MatchService.totalRuns}"

                    "/"

                    "${MatchService.wickets}",
              ),

              const SizedBox(
                height: 10,
              ),

              if(

              MatchService.isSecondInnings

              )

                Text(

                  MatchService.resultText,

                  style: const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                    fontSize: 18,
                  ),
                ),
            ],
          ),

          actions: [

            if(

            !MatchService.isSecondInnings

            )

              TextButton(

                onPressed: (){

                  startSecondInnings();
                },

                child: const Text(
                  "Start 2nd Innings",
                ),
              ),

            if(

            MatchService.isSecondInnings

            )

              TextButton(

                onPressed: () async {

                  await MatchStorageService
                      .clearMatch();

                  MatchService.resetMatch();

                  Navigator.pop(context);

                  Navigator.pop(context);
                },

                child: const Text(
                  "Finish",
                ),
              ),
          ],
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

        style:
        ElevatedButton.styleFrom(

          backgroundColor:
          const Color(
            0xff1E293B,
          ),
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

        title: Text(

          "${MatchService.teamAName}"

              " vs "

              "${MatchService.teamBName}",
        ),
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(16),

        child: Column(

          children: [

            // SCORE CARD

            Container(

              width: double.infinity,

              padding:
              const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color:
                const Color(
                  0xff1E293B,
                ),

                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),

              child: Column(

                children: [

                  Text(

                    "${MatchService.totalRuns}"
                        "/"
                        "${MatchService.wickets}",

                    style: const TextStyle(

                      fontSize: 45,

                      fontWeight:
                      FontWeight.bold,

                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    "Overs "
                        "${MatchService.over}"
                        "."
                        "${MatchService.ball}"
                        " / "
                        "${MatchService.totalOvers}",

                    style: const TextStyle(

                      fontSize: 18,

                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceAround,

                    children: [

                      statBox(

                        "CRR",

                        MatchService
                            .getCurrentRunRate()
                            .toStringAsFixed(
                          2,
                        ),
                      ),

                      statBox(

                        "RRR",

                        MatchService
                            .getRequiredRunRate()
                            .toStringAsFixed(
                          2,
                        ),
                      ),
                    ],
                  ),

                  if(

                  MatchService
                      .isSecondInnings

                  )

                    Padding(

                      padding:
                      const EdgeInsets.only(
                        top: 15,
                      ),

                      child: Text(

                        "Need "
                            "${MatchService.getRemainingRuns()}"
                            " runs in "
                            "${MatchService.getRemainingBalls()}"
                            " balls",

                        style: const TextStyle(

                          fontSize: 17,

                          color: Colors.orange,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            playerCard(

              title: "Striker",

              player: striker,

              isStriker: true,
            ),

            const SizedBox(
              height: 15,
            ),

            playerCard(

              title: "Non Striker",

              player: nonStriker,
            ),

            const SizedBox(
              height: 15,
            ),

            bowlerCard(),

            const SizedBox(
              height: 25,
            ),

            Wrap(

              spacing: 10,

              runSpacing: 10,

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

                runButton("RO", (){
                  addRunOut();
                }),

                runButton("WD", (){
                  addWide();
                }),

                runButton("NB", (){
                  addNoBall();
                }),
              ],
            ),

            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}
