import 'package:flutter/material.dart';

import '../models/player_model.dart';

import '../services/match_service.dart';
import '../services/match_storage_service.dart';

import 'live_score_screen.dart';

class MatchSetupScreen extends StatefulWidget {
  final List<PlayerModel> battingPlayers;

  final List<PlayerModel> bowlingPlayers;

  const MatchSetupScreen({
    super.key,

    required this.battingPlayers,

    required this.bowlingPlayers,
  });

  @override
  State<MatchSetupScreen> createState() => _MatchSetupScreenState();
}

class _MatchSetupScreenState extends State<MatchSetupScreen> {
  // =========================
  // SELECTED PLAYERS
  // =========================

  PlayerModel? selectedStriker;

  PlayerModel? selectedNonStriker;

  PlayerModel? selectedBowler;

  // =========================
  // START MATCH
  // =========================

  Future<void> startMatch() async {
    if (selectedStriker == null ||
        selectedNonStriker == null ||
        selectedBowler == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select all players")));

      return;
    }

    // SAVE PLAYERS

    MatchService.striker = selectedStriker;

    MatchService.nonStriker = selectedNonStriker;

    MatchService.currentBowler = selectedBowler;

    // SAVE MATCH

    await MatchStorageService.saveMatch();

    // OPEN LIVE SCORE

    //    Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) {
    //       return LiveScoreScreen(
    //         final player1Controller = TextEditingController();
    // final player2Controller = TextEditingController();
    // final bowlerController = TextEditingController();
    //       );
    //     },
    //   ),
    // );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LiveScoreScreen(
            matchData: {
              "striker": selectedStriker!.name,
              "nonStriker": selectedNonStriker!.name,
              "bowler": selectedBowler!.name,
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Match Setup"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =========================
            // STRIKER
            // =========================
            const Text(
              "Select Striker",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<PlayerModel>(
              initialValue: selectedStriker,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              items: widget.battingPlayers.map((player) {
                return DropdownMenuItem(
                  value: player,

                  child: Text(player.name),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedStriker = value;

                  // SAME PLAYER FIX

                  if (selectedStriker == selectedNonStriker) {
                    selectedNonStriker = null;
                  }
                });
              },
            ),

            const SizedBox(height: 25),

            // =========================
            // NON STRIKER
            // =========================
            const Text(
              "Select Non Striker",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<PlayerModel>(
              initialValue: selectedNonStriker,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              items: widget.battingPlayers
                  .where((player) {
                    return player != selectedStriker;
                  })
                  .map((player) {
                    return DropdownMenuItem(
                      value: player,

                      child: Text(player.name),
                    );
                  })
                  .toList(),

              onChanged: (value) {
                setState(() {
                  selectedNonStriker = value;
                });
              },
            ),

            const SizedBox(height: 25),

            // =========================
            // BOWLER
            // =========================
            const Text(
              "Select Opening Bowler",

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<PlayerModel>(
              initialValue: selectedBowler,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              items: widget.bowlingPlayers.map((player) {
                return DropdownMenuItem(
                  value: player,

                  child: Text(player.name),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedBowler = value;
                });
              },
            ),

            const SizedBox(height: 40),

            // =========================
            // START BUTTON
            // =========================
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

                onPressed: startMatch,

                child: const Text(
                  "Start Live Match",

                  style: TextStyle(
                    fontSize: 20,

                    color: Colors.white,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
