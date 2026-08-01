import 'package:flutter/material.dart';

import '../services/match_service.dart';

class ScorecardScreen extends StatelessWidget {
  const ScorecardScreen({super.key});

  // =========================
  // LIVE (CURRENT) INNINGS DATA
  // =========================

  Map<String, int> _currentFoursSixes(bool sixes) {
    final Map<String, int> result = {};

    for (final b in MatchService.ballHistory) {
      if (b.isBye || b.isLegBye || b.strikerId.isEmpty) continue;

      if (sixes && b.runs == 6) {
        result[b.strikerId] = (result[b.strikerId] ?? 0) + 1;
      }
      if (!sixes && b.runs == 4) {
        result[b.strikerId] = (result[b.strikerId] ?? 0) + 1;
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final showFirstInnings = MatchService.isSecondInnings;

    return Scaffold(
      appBar: AppBar(title: const Text("Scorecard"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (showFirstInnings) ...[
            _inningsHeader(
              MatchService.teamAName,
              MatchService.firstInningsScore,
              MatchService.firstInningsWickets,
            ),
            const SizedBox(height: 10),
            _battingTableFromSnapshot(MatchService.firstInningsBattingCard),
            const SizedBox(height: 16),
            _bowlingTableFromSnapshot(MatchService.firstInningsBowlingCard),
            const SizedBox(height: 16),
            _fowFromSnapshot(MatchService.firstInningsFallOfWickets),
            const Divider(height: 40, thickness: 1),
          ],

          _inningsHeader(
            MatchService.isSecondInnings
                ? MatchService.teamBName
                : MatchService.teamAName,
            MatchService.totalRuns,
            MatchService.wickets,
          ),
          const SizedBox(height: 10),
          _battingTableLive(),
          const SizedBox(height: 16),
          _bowlingTableLive(),
          const SizedBox(height: 16),
          _fowFromSnapshot(MatchService.fallOfWickets),
        ],
      ),
    );
  }

  Widget _inningsHeader(String team, int runs, int wkts) {
    return Text(
      "$team  $runs/$wkts",
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // =========================
  // BATTING TABLE (LIVE)
  // =========================

  Widget _battingTableLive() {
    final fours = _currentFoursSixes(false);
    final sixes = _currentFoursSixes(true);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Batting",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _battingHeaderRow(),
            const Divider(),
            for (final p in MatchService.battingPlayers)
              if (p.balls > 0 ||
                  MatchService.outPlayers.any((o) => o.id == p.id) ||
                  p.id == MatchService.striker?.id ||
                  p.id == MatchService.nonStriker?.id)
                _battingDataRow(
                  name: p.name,
                  isOut: MatchService.outPlayers.any((o) => o.id == p.id),
                  isNotOut:
                      p.id == MatchService.striker?.id ||
                      p.id == MatchService.nonStriker?.id,
                  runs: p.runs,
                  balls: p.balls,
                  fours: fours[p.id] ?? 0,
                  sixes: sixes[p.id] ?? 0,
                ),
          ],
        ),
      ),
    );
  }

  Widget _battingTableFromSnapshot(List<Map<String, dynamic>> card) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Batting",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _battingHeaderRow(),
            const Divider(),
            for (final e in card)
              if ((e['balls'] as int) > 0 || (e['out'] as bool))
                _battingDataRow(
                  name: e['name'],
                  isOut: e['out'],
                  isNotOut: !(e['out'] as bool),
                  runs: e['runs'],
                  balls: e['balls'],
                  fours: e['fours'],
                  sixes: e['sixes'],
                ),
          ],
        ),
      ),
    );
  }

  Widget _battingHeaderRow() {
    return const Row(
      children: [
        Expanded(flex: 3, child: Text("Batsman", style: TextStyle(color: Colors.grey))),
        Expanded(child: Text("R", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        Expanded(child: Text("B", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        Expanded(child: Text("4s", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        Expanded(child: Text("6s", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        Expanded(child: Text("SR", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
      ],
    );
  }

  Widget _battingDataRow({
    required String name,
    required bool isOut,
    required bool isNotOut,
    required int runs,
    required int balls,
    required int fours,
    required int sixes,
  }) {
    final sr = balls == 0 ? 0.0 : (runs / balls) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              isNotOut ? "$name *" : name,
              style: TextStyle(
                fontWeight: isNotOut ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(child: Text("$runs", textAlign: TextAlign.center)),
          Expanded(child: Text("$balls", textAlign: TextAlign.center)),
          Expanded(child: Text("$fours", textAlign: TextAlign.center)),
          Expanded(child: Text("$sixes", textAlign: TextAlign.center)),
          Expanded(
            child: Text(sr.toStringAsFixed(1), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  // =========================
  // BOWLING TABLE
  // =========================

  Widget _bowlingTableLive() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bowling",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _bowlingHeaderRow(),
            const Divider(),
            for (final p in MatchService.bowlingPlayers)
              if (p.ballsBowled > 0)
                _bowlingDataRow(
                  name: p.name,
                  ballsBowled: p.ballsBowled,
                  runsGiven: p.runsGiven,
                  wickets: p.wickets,
                ),
          ],
        ),
      ),
    );
  }

  Widget _bowlingTableFromSnapshot(List<Map<String, dynamic>> card) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bowling",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _bowlingHeaderRow(),
            const Divider(),
            for (final e in card)
              if ((e['ballsBowled'] as int) > 0)
                _bowlingDataRow(
                  name: e['name'],
                  ballsBowled: e['ballsBowled'],
                  runsGiven: e['runsGiven'],
                  wickets: e['wickets'],
                ),
          ],
        ),
      ),
    );
  }

  Widget _bowlingHeaderRow() {
    return const Row(
      children: [
        Expanded(flex: 3, child: Text("Bowler", style: TextStyle(color: Colors.grey))),
        Expanded(child: Text("O", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        Expanded(child: Text("R", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        Expanded(child: Text("W", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        Expanded(child: Text("Econ", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
      ],
    );
  }

  Widget _bowlingDataRow({
    required String name,
    required int ballsBowled,
    required int runsGiven,
    required int wickets,
  }) {
    final overs = "${ballsBowled ~/ 6}.${ballsBowled % 6}";
    final econ = ballsBowled == 0
        ? 0.0
        : runsGiven / (ballsBowled / 6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name)),
          Expanded(child: Text(overs, textAlign: TextAlign.center)),
          Expanded(child: Text("$runsGiven", textAlign: TextAlign.center)),
          Expanded(child: Text("$wickets", textAlign: TextAlign.center)),
          Expanded(
            child: Text(econ.toStringAsFixed(1), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  // =========================
  // FALL OF WICKETS
  // =========================

  Widget _fowFromSnapshot(List<Map<String, dynamic>> fow) {
    if (fow.isEmpty) return const SizedBox.shrink();

    final text = fow.map((e) {
      return "${e['wicket']}-${e['score']} (${e['player']}, ${e['overs']})";
    }).join("   ");

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fall of Wickets",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
