import 'package:flutter/material.dart';

import '../models/player_model.dart';

import '../services/player_service.dart';
import '../services/match_service.dart';

import 'match_setup_screen.dart';

class StartMatchScreen
    extends StatefulWidget {

  const StartMatchScreen({
    super.key,
  });

  @override
  State<StartMatchScreen>
  createState() =>

      _StartMatchScreenState();
}

class _StartMatchScreenState
    extends State<StartMatchScreen> {

  // =========================
  // CONTROLLERS
  // =========================

  final TextEditingController
  teamAController =
  TextEditingController();

  final TextEditingController
  teamBController =
  TextEditingController();

  final TextEditingController
  oversController =
  TextEditingController();

  // =========================
  // PLAYERS
  // =========================

  List<PlayerModel>
  allPlayers = [];

  List<PlayerModel>
  teamAPlayers = [];

  List<PlayerModel>
  teamBPlayers = [];

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();

    loadPlayers();
  }

  // =========================
  // LOAD PLAYERS
  // =========================

  void loadPlayers(){

    allPlayers =
        PlayerService.getPlayers();

    setState(() {});
  }

  // =========================
  // PLAYER TILE
  // =========================

  Widget playerTile({

    required PlayerModel player,

    required bool isTeamA,

  }) {

    bool selected =

    isTeamA

        ?

    teamAPlayers.contains(player)

        :

    teamBPlayers.contains(player);

    return CheckboxListTile(

      value: selected,

      activeColor: Colors.green,

      title: Text(
        player.name,
      ),

      onChanged: (value){

        setState(() {

          if(isTeamA){

            if(value == true){

              if(!teamAPlayers
                  .contains(player)){

                teamAPlayers
                    .add(player);

                teamBPlayers
                    .remove(player);
              }

            }else{

              teamAPlayers
                  .remove(player);
            }

          }else{

            if(value == true){

              if(!teamBPlayers
                  .contains(player)){

                teamBPlayers
                    .add(player);

                teamAPlayers
                    .remove(player);
              }

            }else{

              teamBPlayers
                  .remove(player);
            }
          }
        });
      },
    );
  }

  // =========================
  // START MATCH
  // =========================

  void startMatch(){

    String teamA =
    teamAController.text
        .trim();

    String teamB =
    teamBController.text
        .trim();

    String overs =
    oversController.text
        .trim();

    // VALIDATION

    if(

    teamA.isEmpty ||

        teamB.isEmpty ||

        overs.isEmpty ||

        teamAPlayers.length < 2 ||

        teamBPlayers.length < 2

    ){

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            "Fill all details properly",
          ),
        ),
      );

      return;
    }

    // RESET MATCH

    MatchService.resetMatch();

    // SAVE MATCH INFO

    MatchService.teamAName =
        teamA;

    MatchService.teamBName =
        teamB;

    MatchService.totalOvers =
        int.parse(overs);

    // SAVE PLAYERS

    MatchService.battingPlayers =
        teamAPlayers;

    MatchService.bowlingPlayers =
        teamBPlayers;

    // RESET PLAYER STATS

    MatchService.resetPlayerStats();

    // NEXT SCREEN

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (context){

          return MatchSetupScreen(

            battingPlayers:
            teamAPlayers,

            bowlingPlayers:
            teamBPlayers,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Start Match",
        ),

        centerTitle: true,
      ),

      body: allPlayers.isEmpty

          ? const Center(

        child: Text(

          "No Players Found\nAdd Players First",

          textAlign:
          TextAlign.center,

          style: TextStyle(
            fontSize: 18,
          ),
        ),
      )

          : SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // =========================
            // TEAM A
            // =========================

            TextField(

              controller:
              teamAController,

              decoration:
              InputDecoration(

                hintText:
                "Team A Name",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =========================
            // TEAM B
            // =========================

            TextField(

              controller:
              teamBController,

              decoration:
              InputDecoration(

                hintText:
                "Team B Name",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // =========================
            // OVERS
            // =========================

            TextField(

              controller:
              oversController,

              keyboardType:
              TextInputType.number,

              decoration:
              InputDecoration(

                hintText:
                "Total Overs",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // =========================
            // TEAM A PLAYERS
            // =========================

            const Text(

              "Select Team A Players",

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Container(

              height: 250,

              decoration:
              BoxDecoration(

                border: Border.all(
                  color: Colors.grey,
                ),

                borderRadius:
                BorderRadius.circular(
                  15,
                ),
              ),

              child: ListView.builder(

                itemCount:
                allPlayers.length,

                itemBuilder:
                    (context, index){

                  return playerTile(

                    player:
                    allPlayers[index],

                    isTeamA: true,
                  );
                },
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // =========================
            // TEAM B PLAYERS
            // =========================

            const Text(

              "Select Team B Players",

              style: TextStyle(

                fontSize: 20,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Container(

              height: 250,

              decoration:
              BoxDecoration(

                border: Border.all(
                  color: Colors.grey,
                ),

                borderRadius:
                BorderRadius.circular(
                  15,
                ),
              ),

              child: ListView.builder(

                itemCount:
                allPlayers.length,

                itemBuilder:
                    (context, index){

                  return playerTile(

                    player:
                    allPlayers[index],

                    isTeamA: false,
                  );
                },
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // =========================
            // START BUTTON
            // =========================

            SizedBox(

              width:
              double.infinity,

              height: 65,

              child: ElevatedButton(

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.green,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                ),

                onPressed:
                startMatch,

                child: const Text(

                  "Continue Match Setup",

                  style: TextStyle(

                    fontSize: 20,

                    color:
                    Colors.white,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}