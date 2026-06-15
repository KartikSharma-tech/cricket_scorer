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
  // STRIKE CHANGE
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
  // CHECK MATCH RESULT
  // =========================

  void checkMatchResult(){

    MatchService.checkWinner();

    if(MatchService.isMatchEnded){

      showInningsCompleteDialog();
    }
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
                  .length - 1;

      // STRIKE ROTATE

      if(!soloPlayer){

        if(

        run == 1 ||
            run == 3 ||
            run == 5

        ){

          swapStrike();
        }
      }

      // OVER COMPLETE

      if(MatchService.ball == 6){

        MatchService.over++;

        MatchService.ball = 0;

        if(!soloPlayer){

          swapStrike();
        }

        // OVERS END

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

      // SECOND INNINGS WIN CHECK

      if(MatchService.isSecondInnings){

        checkMatchResult();
      }

      MatchStorageService.saveMatch();
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

      MatchStorageService.saveMatch();
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

      MatchStorageService.saveMatch();
    });
  }

  // =========================
  // WICKET
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
              .length

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

      // REMAINING PLAYERS

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

      // NEW BATSMAN

      if(remainingPlayers.isNotEmpty){

        showNewBatsmanDialog(
            remainingPlayers);

      }else{

        MatchService.striker =
            MatchService.nonStriker;
      }

      // OVER COMPLETE

      if(MatchService.ball == 6){

        MatchService.over++;

        MatchService.ball = 0;

        bool soloPlayer =

            MatchService.wickets >=

                MatchService
                    .battingPlayers
                    .length - 1;

        if(!soloPlayer){

          swapStrike();
        }

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

      MatchStorageService.saveMatch();
    });
  }

  // =========================
  // RUN OUT
  // =========================

  void addRunOut(){

    if(MatchService.isMatchEnded){
      return;
    }

    setState(() {

      MatchService.wickets++;

      striker.balls++;

      MatchService.ball++;

      MatchService.outPlayers
          .add(striker);

      // ALL OUT

      if(

      MatchService.wickets >=

          MatchService
              .battingPlayers
              .length

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

      // REMAINING PLAYERS

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
            remainingPlayers);

      }else{

        MatchService.striker =
            MatchService.nonStriker;
      }

      // OVER COMPLETE

      if(MatchService.ball == 6){

        MatchService.over++;

        MatchService.ball = 0;

        showBowlerDialog();
      }

      MatchStorageService.saveMatch();
    });
  }

  // =========================
  // RUN RATE
  // =========================

  double getCurrentRunRate(){

    return MatchService
        .getCurrentRunRate();
  }

  double getRequiredRunRate(){

    return MatchService
        .getRequiredRunRate();
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
  // SECOND INNINGS START
  // =========================

  void startSecondInnings(){

    Navigator.pop(context);

    MatchService.firstInningsScore =
        MatchService.totalRuns;

    MatchService.target =
        MatchService.firstInningsScore + 1;

    MatchService.isSecondInnings =
    true;

    // SWAP TEAMS

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

                  mainAxisSize:
                  MainAxisSize.min,

                  children: [

                    DropdownButton<PlayerModel>(

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

                    DropdownButton<PlayerModel>(

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

                    DropdownButton<PlayerModel>(

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

                    selectedStriker == null ||

                        selectedNonStriker
                            == null ||

                        selectedBowler
                            == null

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
  // INNINGS COMPLETE
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

            // START SECOND INNINGS

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

            // FINISH MATCH

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
        const EdgeInsets.all(20),

        child: Column(

          children: [

            // SCORE CARD

            Container(

              width:
              double.infinity,

              padding:
              const EdgeInsets.all(25),

              decoration:
              BoxDecoration(

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

                      fontSize: 40,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    "Overs : "

                        "${MatchService.over}"
                        "."
                        "${MatchService.ball}"

                        " / "

                        "${MatchService.totalOvers}",
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  if(

                  MatchService.isSecondInnings

                  )

                    Text(

                      "Target : ${MatchService.target}",
                    ),

                  const SizedBox(
                    height: 5,
                  ),

                  if(

                  MatchService.isSecondInnings

                  )

                    Text(

                      "Need "

                          "${MatchService.getRemainingRuns()}"

                          " runs in "

                          "${MatchService.getRemainingBalls()}"

                          " balls",
                    ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    "CRR : "

                        "${getCurrentRunRate().toStringAsFixed(2)}",
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(

                    "RRR : "

                        "${getRequiredRunRate().toStringAsFixed(2)}",
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    "Extras : "

                        "${MatchService.getTotalExtras()}",
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // STRIKER

            Container(

              width:
              double.infinity,

              padding:
              const EdgeInsets.all(20),

              decoration:
              BoxDecoration(

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

                  const SizedBox(
                    height: 15,
                  ),

                  Text(striker.name),

                  Text(
                    "Runs : ${striker.runs}",
                  ),

                  Text(
                    "Balls : ${striker.balls}",
                  ),

                  Text(
                    "SR : ${getStrikeRate(striker).toStringAsFixed(1)}",
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // NON STRIKER

            Container(

              width:
              double.infinity,

              padding:
              const EdgeInsets.all(20),

              decoration:
              BoxDecoration(

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

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const Text(

                    "Non Striker",

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Text(nonStriker.name),

                  Text(
                    "Runs : ${nonStriker.runs}",
                  ),

                  Text(
                    "Balls : ${nonStriker.balls}",
                  ),

                  Text(
                    "SR : ${getStrikeRate(nonStriker).toStringAsFixed(1)}",
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // BOWLER

            Container(

              width:
              double.infinity,

              padding:
              const EdgeInsets.all(20),

              decoration:
              BoxDecoration(

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

                  const SizedBox(
                    height: 15,
                  ),

                  Text(currentBowler.name),

                  Text(
                    "Runs Given : ${currentBowler.runsGiven}",
                  ),

                  Text(
                    "Wickets : ${currentBowler.wickets}",
                  ),

                  Text(
                    "Overs : ${getBowlerOvers()}",
                  ),

                  Text(
                    "Economy : ${getEconomy().toStringAsFixed(1)}",
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

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
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}