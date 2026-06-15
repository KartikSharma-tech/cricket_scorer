import 'package:flutter/material.dart';

import '../models/player_model.dart';

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
  PlayerModel? striker;

  PlayerModel? nonStriker;

  PlayerModel? bowler;

  @override
  void initState() {
    super.initState();

    striker = widget.battingPlayers.first;

    nonStriker = widget.battingPlayers.length > 1
        ? widget.battingPlayers[1]
        : widget.battingPlayers.first;

    bowler = widget.bowlingPlayers.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Match Setup")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // STRIKER
            DropdownButtonFormField<PlayerModel>(
              value: striker,

              decoration: InputDecoration(
                labelText: "Select Striker",

                filled: true,

                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide.none,
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
                  striker = value;
                });
              },
            ),

            const SizedBox(height: 25),

            // NON STRIKER
            DropdownButtonFormField<PlayerModel>(
              value: nonStriker,

              decoration: InputDecoration(
                labelText: "Select Non-Striker",

                filled: true,

                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide.none,
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
                  nonStriker = value;
                });
              },
            ),

            const SizedBox(height: 25),

            // BOWLER
            DropdownButtonFormField<PlayerModel>(
              value: bowler,

              decoration: InputDecoration(
                labelText: "Select Opening Bowler",

                filled: true,

                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),

                  borderSide: BorderSide.none,
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
                  bowler = value;
                });
              },
            ),

            const Spacer(),

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
                  if (striker == null || nonStriker == null || bowler == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Select all players")),
                    );

                    return;
                  }

                  if (striker == nonStriker) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Striker and Non-Striker cannot be same"),
                      ),
                    );

                    return;
                  }

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) => LiveScoreScreen(
                        battingPlayers: widget.battingPlayers,

                        bowlingPlayers: widget.bowlingPlayers,

                        strikerPlayer: striker!,

                        nonStrikerPlayer: nonStriker!,

                        bowlerPlayer: bowler!,
                      ),
                    ),
                  );
                },

                child: const Text(
                  "Start Live Match",

                  style: TextStyle(
                    fontSize: 22,

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
