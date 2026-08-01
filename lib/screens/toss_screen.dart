import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/match_service.dart';
import 'match_setup_screen.dart';

class TossScreen extends StatefulWidget {
  final List<PlayerModel> teamAPlayers;
  final List<PlayerModel> teamBPlayers;
  final int overs;

  const TossScreen({
    super.key,
    required this.teamAPlayers,
    required this.teamBPlayers,
    required this.overs,
  });

  @override
  State<TossScreen> createState() => _TossScreenState();
}

class _TossScreenState extends State<TossScreen> {
  String? tossWinner; // "A" or "B"

  void _chooseWinner(String team) {
    setState(() => tossWinner = team);
  }

  void _chooseDecision(String decision) {
    // decision = "Bat" or "Bowl"

    final winnerName = tossWinner == "A"
        ? MatchService.teamAName
        : MatchService.teamBName;

    MatchService.tossResult = "$winnerName won the toss and chose to $decision";

    final bool teamABatsFirst =
        (tossWinner == "A" && decision == "Bat") ||
        (tossWinner == "B" && decision == "Bowl");

    MatchService.battingPlayers = teamABatsFirst
        ? widget.teamAPlayers
        : widget.teamBPlayers;

    MatchService.bowlingPlayers = teamABatsFirst
        ? widget.teamBPlayers
        : widget.teamAPlayers;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MatchSetupScreen(
            battingPlayers: MatchService.battingPlayers,
            bowlingPlayers: MatchService.bowlingPlayers,
            overs: widget.overs,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Toss"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.circle, size: 70, color: Colors.amber),

            const SizedBox(height: 24),

            Text(
              tossWinner == null
                  ? "Who won the toss?"
                  : "${tossWinner == 'A' ? MatchService.teamAName : MatchService.teamBName} won the toss.\nElected to?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            if (tossWinner == null) ...[
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _chooseWinner("A"),
                  child: Text(
                    MatchService.teamAName,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _chooseWinner("B"),
                  child: Text(
                    MatchService.teamBName,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _chooseDecision("Bat"),
                  child: const Text(
                    "Bat First",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _chooseDecision("Bowl"),
                  child: const Text(
                    "Bowl First",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => tossWinner = null),
                child: const Text("Back"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
