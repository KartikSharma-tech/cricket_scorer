import 'package:flutter/material.dart';

import '../models/match_history_model.dart';
import '../services/hive_service.dart';
import '../services/match_service.dart';
import '../services/match_storage_service.dart';
import 'navigation_screen.dart';

class MatchResultScreen extends StatefulWidget {
  const MatchResultScreen({super.key});

  @override
  State<MatchResultScreen> createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  bool saved = false;

  @override
  void initState() {
    super.initState();

    saveHistory();
  }

  // =========================
  // SAVE TO MATCH HISTORY (once)
  // =========================

  Future<void> saveHistory() async {
    if (saved) return;

    saved = true;

    // TEAM A ALWAYS BATS FIRST IN THIS APP'S FLOW

    final match = MatchHistoryModel(
      teamAName: MatchService.teamAName,
      teamBName: MatchService.teamBName,
      teamAScore: MatchService.firstInningsScore,
      teamAWickets: MatchService.firstInningsWickets,
      teamBScore: MatchService.totalRuns,
      teamBWickets: MatchService.wickets,
      overs: MatchService.totalOvers,
      result: MatchService.resultText,
      winner: _winnerName(),
      matchDate: DateTime.now(),
    );

    await HiveService.saveMatchHistory(match);

    // BUMP "MATCHES PLAYED" FOR EVERYONE WHO TOOK PART

    for (final player in [
      ...MatchService.battingPlayers,
      ...MatchService.bowlingPlayers,
    ]) {
      player.matches += 1;
    }

    // CLEAR THE LIVE MATCH SO "RESUME MATCH" DISAPPEARS

    await MatchStorageService.clearMatch();
  }

  String _winnerName() {
    final result = MatchService.resultText;

    if (result.contains(MatchService.teamAName)) {
      return MatchService.teamAName;
    }

    if (result.contains(MatchService.teamBName)) {
      return MatchService.teamBName;
    }

    return "Tie";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Match Result"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.emoji_events,
              size: 90,
              color: Colors.amber,
            ),

            const SizedBox(height: 20),

            Text(
              MatchService.resultText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            _scoreLine(
              MatchService.teamAName,
              MatchService.firstInningsScore,
              MatchService.firstInningsWickets,
            ),

            const SizedBox(height: 10),

            _scoreLine(
              MatchService.teamBName,
              MatchService.totalRuns,
              MatchService.wickets,
            ),

            const SizedBox(height: 50),

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

                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const NavigationScreen(),
                    ),
                    (route) => false,
                  );
                },

                child: const Text(
                  "Back to Home",
                  style: TextStyle(
                    fontSize: 18,
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

  Widget _scoreLine(String team, int runs, int wkts) {
    return Text(
      "$team : $runs / $wkts",
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }
}
