import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/player_service.dart';

import 'match_setup_screen.dart';

class StartMatchScreen extends StatefulWidget {
  const StartMatchScreen({super.key});

  @override
  State<StartMatchScreen> createState() => _StartMatchScreenState();
}

class _StartMatchScreenState extends State<StartMatchScreen> {
  final TextEditingController teamAController = TextEditingController();

  final TextEditingController teamBController = TextEditingController();

  final TextEditingController oversController = TextEditingController();

  List<PlayerModel> allPlayers = PlayerService.allPlayers;

  List<PlayerModel> teamAPlayers = [];

  List<PlayerModel> teamBPlayers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start Match")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // TEAM A NAME
            TextField(
              controller: teamAController,

              decoration: InputDecoration(
                hintText: "Team A Name",

                filled: true,

                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TEAM B NAME
            TextField(
              controller: teamBController,

              decoration: InputDecoration(
                hintText: "Team B Name",

                filled: true,

                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // OVERS
            TextField(
              controller: oversController,

              keyboardType: TextInputType.number,

              decoration: InputDecoration(
                hintText: "Overs",

                filled: true,

                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // TEAM A PLAYERS
            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                "Select Team A Players",

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 250,

              child: ListView.builder(
                itemCount: allPlayers.length,

                itemBuilder: (context, index) {
                  PlayerModel player = allPlayers[index];

                  return CheckboxListTile(
                    value: teamAPlayers.contains(player),

                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (!teamAPlayers.contains(player)) {
                            teamAPlayers.add(player);

                            teamBPlayers.remove(player);
                          }
                        } else {
                          teamAPlayers.remove(player);
                        }
                      });
                    },

                    title: Text(player.name),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // TEAM B PLAYERS
            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                "Select Team B Players",

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 250,

              child: ListView.builder(
                itemCount: allPlayers.length,

                itemBuilder: (context, index) {
                  PlayerModel player = allPlayers[index];

                  return CheckboxListTile(
                    value: teamBPlayers.contains(player),

                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          if (!teamBPlayers.contains(player)) {
                            teamBPlayers.add(player);

                            teamAPlayers.remove(player);
                          }
                        } else {
                          teamBPlayers.remove(player);
                        }
                      });
                    },

                    title: Text(player.name),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // CONTINUE BUTTON
            SizedBox(
              width: double.infinity,

              height: 65,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {
                  // VALIDATION

                  if (teamAController.text.trim().isEmpty ||
                      teamBController.text.trim().isEmpty ||
                      oversController.text.trim().isEmpty ||
                      teamAPlayers.length < 2 ||
                      teamBPlayers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Fill all details properly"),
                      ),
                    );

                    return;
                  }

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) => MatchSetupScreen(
                        battingPlayers: teamAPlayers,

                        bowlingPlayers: teamBPlayers,
                      ),
                    ),
                  );
                },

                child: const Text(
                  "Continue Match Setup",

                  style: TextStyle(
                    fontSize: 22,

                    color: Colors.white,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
