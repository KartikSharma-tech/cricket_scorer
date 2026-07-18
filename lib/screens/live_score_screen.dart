import 'package:flutter/material.dart';

import '../models/ball_model.dart';
import '../models/player_model.dart';
import '../services/match_service.dart';
import '../services/match_storage_service.dart';
import 'match_result_screen.dart';

class LiveScoreScreen extends StatefulWidget {
  const LiveScoreScreen({super.key});

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen> {
  // =========================
  // UNDO STACK (full state snapshots)
  // =========================

  final List<Map<String, dynamic>> _undoStack = [];

  bool _busy = false;

  // =========================
  // ID GENERATOR
  // =========================

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // =========================
  // SNAPSHOT (for undo)
  // =========================

  Map<String, dynamic> _snapshot() {
    return {
      'totalRuns': MatchService.totalRuns,
      'wickets': MatchService.wickets,
      'over': MatchService.over,
      'ball': MatchService.ball,
      'wides': MatchService.wides,
      'noBalls': MatchService.noBalls,
      'byes': MatchService.byes,
      'legByes': MatchService.legByes,
      'isMatchEnded': MatchService.isMatchEnded,
      'strikerId': MatchService.striker?.id,
      'strikerRuns': MatchService.striker?.runs,
      'strikerBalls': MatchService.striker?.balls,
      'nonStrikerId': MatchService.nonStriker?.id,
      'nonStrikerRuns': MatchService.nonStriker?.runs,
      'nonStrikerBalls': MatchService.nonStriker?.balls,
      'bowlerId': MatchService.currentBowler?.id,
      'bowlerRuns': MatchService.currentBowler?.runsGiven,
      'bowlerBalls': MatchService.currentBowler?.ballsBowled,
      'bowlerWickets': MatchService.currentBowler?.wickets,
      'previousBowlerId': MatchService.previousBowler?.id,
      'outPlayerIds': MatchService.outPlayers.map((p) => p.id).toList(),
      'ballHistoryLen': MatchService.ballHistory.length,
      'thisOverLen': MatchService.thisOverBalls.length,
    };
  }

  void _pushUndo() {
    _undoStack.add(_snapshot());
    if (_undoStack.length > 60) {
      _undoStack.removeAt(0);
    }
  }

  PlayerModel? _findPlayer(String? id, List<PlayerModel> list) {
    if (id == null) return null;
    final matches = list.where((p) => p.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  void _restore(Map<String, dynamic> s) {
    MatchService.totalRuns = s['totalRuns'];
    MatchService.wickets = s['wickets'];
    MatchService.over = s['over'];
    MatchService.ball = s['ball'];
    MatchService.wides = s['wides'];
    MatchService.noBalls = s['noBalls'];
    MatchService.byes = s['byes'];
    MatchService.legByes = s['legByes'];
    MatchService.isMatchEnded = s['isMatchEnded'];

    final strikerP = _findPlayer(s['strikerId'], MatchService.battingPlayers);
    if (strikerP != null) {
      strikerP.runs = s['strikerRuns'];
      strikerP.balls = s['strikerBalls'];
    }
    MatchService.striker = strikerP;

    final nonStrikerP = _findPlayer(
      s['nonStrikerId'],
      MatchService.battingPlayers,
    );
    if (nonStrikerP != null) {
      nonStrikerP.runs = s['nonStrikerRuns'];
      nonStrikerP.balls = s['nonStrikerBalls'];
    }
    MatchService.nonStriker = nonStrikerP;

    final bowlerP = _findPlayer(s['bowlerId'], MatchService.bowlingPlayers);
    if (bowlerP != null) {
      bowlerP.runsGiven = s['bowlerRuns'];
      bowlerP.ballsBowled = s['bowlerBalls'];
      bowlerP.wickets = s['bowlerWickets'];
    }
    MatchService.currentBowler = bowlerP;

    MatchService.previousBowler = _findPlayer(
      s['previousBowlerId'],
      MatchService.bowlingPlayers,
    );

    final List<String> outIds = List<String>.from(s['outPlayerIds']);
    MatchService.outPlayers = MatchService.battingPlayers
        .where((p) => outIds.contains(p.id))
        .toList();

    final int ballHistLen = s['ballHistoryLen'];
    while (MatchService.ballHistory.length > ballHistLen) {
      MatchService.ballHistory.removeLast();
    }

    final int thisOverLen = s['thisOverLen'];
    while (MatchService.thisOverBalls.length > thisOverLen) {
      MatchService.thisOverBalls.removeLast();
    }
  }

  Future<void> _undo() async {
    if (_undoStack.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Nothing to undo")));
      return;
    }

    final snap = _undoStack.removeLast();
    _restore(snap);
    setState(() {});
    await MatchStorageService.saveMatch();
  }

  // =========================
  // STRIKE ROTATION
  // =========================

  void _rotateStrike() {
    final temp = MatchService.striker;
    MatchService.striker = MatchService.nonStriker;
    MatchService.nonStriker = temp;
  }

  // =========================
  // SCORING ACTIONS
  // =========================

  Future<void> _addRun(int runs) async {
    if (_guardBlocked()) return;

    _pushUndo();

    final striker = MatchService.striker!;
    striker.runs += runs;
    striker.balls += 1;

    MatchService.totalRuns += runs;
    MatchService.currentBowler!.runsGiven += runs;

    final ball = BallModel(id: _newId(), runs: runs);
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    final overCompleted = MatchService.recordLegalBall();

    if (runs % 2 == 1) _rotateStrike();

    await _afterBall(overCompleted);
  }

  Future<void> _addWide(int extra) async {
    if (_guardBlocked()) return;

    _pushUndo();

    MatchService.totalRuns += 1 + extra;
    MatchService.wides += 1 + extra;
    MatchService.currentBowler!.runsGiven += 1 + extra;

    final ball = BallModel(
      id: _newId(),
      runs: 0,
      isWide: true,
      extraRuns: extra,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    if (extra % 2 == 1) _rotateStrike();

    await _afterBall(false);
  }

  Future<void> _addNoBall(int batRuns) async {
    if (_guardBlocked()) return;

    _pushUndo();

    final striker = MatchService.striker!;
    striker.runs += batRuns;
    if (batRuns > 0) striker.balls += 1;

    MatchService.totalRuns += batRuns + 1;
    MatchService.noBalls += 1;
    MatchService.currentBowler!.runsGiven += batRuns + 1;

    final ball = BallModel(id: _newId(), runs: batRuns, isNoBall: true);
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    if (batRuns % 2 == 1) _rotateStrike();

    await _afterBall(false);
  }

  Future<void> _addExtraRun(int runs, {required bool isLegBye}) async {
    if (_guardBlocked()) return;

    _pushUndo();

    MatchService.striker!.balls += 1;
    MatchService.totalRuns += runs;

    if (isLegBye) {
      MatchService.legByes += runs;
    } else {
      MatchService.byes += runs;
    }

    final ball = BallModel(
      id: _newId(),
      runs: runs,
      isBye: !isLegBye,
      isLegBye: isLegBye,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    final overCompleted = MatchService.recordLegalBall();

    if (runs % 2 == 1) _rotateStrike();

    await _afterBall(overCompleted);
  }

  Future<void> _addWicket(String type) async {
    if (_guardBlocked()) return;

    _pushUndo();

    final out = MatchService.striker!;
    out.balls += 1;

    MatchService.wickets += 1;
    MatchService.currentBowler!.wickets += 1;
    MatchService.outPlayers.add(out);

    final ball = BallModel(
      id: _newId(),
      runs: 0,
      isWicket: true,
      wicketType: type,
      outPlayerId: out.id,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    final overCompleted = MatchService.recordLegalBall();

    MatchService.striker = null;

    await _afterBall(overCompleted, wicketFell: true);
  }

  Future<void> _addRunOut({
    required bool strikerIsOut,
    required int runsCompleted,
  }) async {
    if (_guardBlocked()) return;

    _pushUndo();

    final striker = MatchService.striker!;
    striker.balls += 1;
    striker.runs += runsCompleted;

    MatchService.totalRuns += runsCompleted;
    MatchService.currentBowler!.runsGiven += runsCompleted;
    MatchService.wickets += 1;

    final outPlayer = strikerIsOut
        ? MatchService.striker!
        : MatchService.nonStriker!;
    MatchService.outPlayers.add(outPlayer);

    final ball = BallModel(
      id: _newId(),
      runs: runsCompleted,
      isWicket: true,
      wicketType: 'Run Out',
      outPlayerId: outPlayer.id,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    final overCompleted = MatchService.recordLegalBall();

    if (strikerIsOut) {
      MatchService.striker = null;
    } else {
      MatchService.nonStriker = null;
    }

    await _afterBall(overCompleted, wicketFell: true);
  }

  bool _guardBlocked() {
    if (MatchService.isMatchEnded) return true;
    if (MatchService.striker == null) return true;
    if (MatchService.nonStriker == null && !MatchService.isLastManStanding) {
      return true;
    }
    if (MatchService.currentBowler == null) return true;
    return false;
  }

  // =========================
  // AFTER-BALL FLOW
  // =========================

  Future<void> _afterBall(bool overCompleted, {bool wicketFell = false}) async {
    if (!mounted) return;
    setState(() {});
    await MatchStorageService.saveMatch();

    // INNINGS OVER (all out or overs finished)
    if (MatchService.inningsCompleted) {
      if (!MatchService.isSecondInnings) {
        await _startSecondInningsFlow();
      } else {
        MatchService.checkWinner();
        await MatchStorageService.saveMatch();
        if (MatchService.isMatchEnded && mounted) {
          _goToResult();
        }
      }
      return;
    }

    // TARGET CHASED DOWN (can happen mid-over)
    if (MatchService.isSecondInnings && MatchService.targetAchieved) {
      MatchService.checkWinner();
      await MatchStorageService.saveMatch();
      if (MatchService.isMatchEnded && mounted) {
        _goToResult();
        return;
      }
    }

    // A WICKET FELL BUT THE INNINGS CONTINUES
    if (wicketFell) {
      if (MatchService.isLastManStanding) {
        // Solo batsman: move whoever survived onto strike.
        if (MatchService.striker == null && MatchService.nonStriker != null) {
          MatchService.striker = MatchService.nonStriker;
          MatchService.nonStriker = null;
        }
        setState(() {});
      } else if (MatchService.striker == null ||
          MatchService.nonStriker == null) {
        await _pickNextBatsman();
      }
    }

    // OVER JUST COMPLETED - NEW BOWLER REQUIRED
    if (overCompleted &&
        !MatchService.inningsCompleted &&
        MatchService.currentBowler == null) {
      await _pickNextBowler();
    }

    if (mounted) setState(() {});
  }

  Future<void> _startSecondInningsFlow() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Innings Break"),
        content: Text(
          "${MatchService.teamAName} scored "
          "${MatchService.totalRuns}/${MatchService.wickets}.\n\n"
          "${MatchService.teamBName} need "
          "${MatchService.totalRuns + 1} runs to win.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Start 2nd Innings"),
          ),
        ],
      ),
    );

    setState(() {
      MatchService.startSecondInnings();
    });

    _undoStack.clear();

    await MatchStorageService.saveMatch();

    await _pickNextBatsman(); // fills striker
    if (!mounted) return;
    await _pickNextBatsman(); // fills non-striker
    if (!mounted) return;
    await _pickNextBowler();

    if (mounted) setState(() {});
    await MatchStorageService.saveMatch();
  }

  void _goToResult() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MatchResultScreen()),
    );
  }

  // =========================
  // PLAYER / BOWLER PICKERS
  // =========================

  Future<void> _pickNextBatsman() async {
    if (!mounted) return;

    final available = MatchService.battingPlayers.where((p) {
      final isOut = MatchService.outPlayers.any((o) => o.id == p.id);
      final isCurrentlyIn =
          p.id == MatchService.striker?.id ||
          p.id == MatchService.nonStriker?.id;
      return !isOut && !isCurrentlyIn;
    }).toList();

    if (available.isEmpty) return;

    final selected = await showDialog<PlayerModel>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SimpleDialog(
        title: const Text("Select Next Batsman"),
        children: available.map((p) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, p),
            child: Text(p.name),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        if (MatchService.striker == null) {
          MatchService.striker = selected;
        } else {
          MatchService.nonStriker = selected;
        }
      });
      await MatchStorageService.saveMatch();
    }
  }

  Future<void> _pickNextBowler() async {
    if (!mounted) return;

    final available = MatchService.bowlingPlayers.where((p) {
      return p.id != MatchService.previousBowler?.id;
    }).toList();

    if (available.isEmpty) return;

    final selected = await showDialog<PlayerModel>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SimpleDialog(
        title: const Text("Select Next Bowler"),
        children: available.map((p) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, p),
            child: Text(p.name),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      setState(() => MatchService.currentBowler = selected);
      await MatchStorageService.saveMatch();
    }
  }

  // =========================
  // WICKET / EXTRAS DIALOGS
  // =========================

  Future<void> _showWicketDialog() async {
    if (_guardBlocked()) return;

    final type = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("How Out?"),
        children: [
          'Bowled',
          'Caught',
          'LBW',
          'Stumped',
          'Hit Wicket',
          'Run Out',
        ].map((t) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, t),
            child: Text(t),
          );
        }).toList(),
      ),
    );

    if (type == null) return;

    if (type == 'Run Out') {
      await _showRunOutDialog();
    } else {
      await _addWicket(type);
    }
  }

  Future<void> _showRunOutDialog() async {
    if (MatchService.isLastManStanding) {
      // Only one batsman on the field - they're the only one who can be out.
      await _addRunOut(strikerIsOut: true, runsCompleted: 0);
      return;
    }

    final strikerOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("Who's Out?"),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(MatchService.striker?.name ?? "Striker"),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MatchService.nonStriker?.name ?? "Non-Striker"),
          ),
        ],
      ),
    );

    if (strikerOut == null) return;

    final runs = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("Runs Completed Before Run Out"),
        children: [0, 1, 2, 3].map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, r),
            child: Text("$r"),
          );
        }).toList(),
      ),
    );

    if (runs == null) return;

    await _addRunOut(strikerIsOut: strikerOut, runsCompleted: runs);
  }

  Future<void> _showWideDialog() async {
    if (_guardBlocked()) return;

    final extra = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("Wide"),
        children: [0, 1, 2, 3, 4].map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, r),
            child: Text(r == 0 ? "Wide only" : "Wide + $r run(s)"),
          );
        }).toList(),
      ),
    );

    if (extra != null) await _addWide(extra);
  }

  Future<void> _showNoBallDialog() async {
    if (_guardBlocked()) return;

    final runs = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("No Ball - Runs off Bat"),
        children: [0, 1, 2, 3, 4, 6].map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, r),
            child: Text("$r"),
          );
        }).toList(),
      ),
    );

    if (runs != null) await _addNoBall(runs);
  }

  Future<void> _showByeDialog(bool isLegBye) async {
    if (_guardBlocked()) return;

    final runs = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(isLegBye ? "Leg Byes" : "Byes"),
        children: [1, 2, 3, 4].map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, r),
            child: Text("$r"),
          );
        }).toList(),
      ),
    );

    if (runs != null) await _addExtraRun(runs, isLegBye: isLegBye);
  }

  // =========================
  // UI HELPERS
  // =========================

  String get _oversText => "${MatchService.over}.${MatchService.ball}";

  String _ballLabel(BallModel b) {
    if (b.isWicket) return "W";
    if (b.isWide) return b.extraRuns > 0 ? "Wd+${b.extraRuns}" : "Wd";
    if (b.isNoBall) return "Nb${b.runs > 0 ? '+${b.runs}' : ''}";
    if (b.isBye) return "${b.runs}B";
    if (b.isLegBye) return "${b.runs}Lb";
    return "${b.runs}";
  }

  Color _ballColor(BallModel b) {
    if (b.isWicket) return Colors.red;
    if (b.isWide || b.isNoBall) return Colors.orange;
    if (b.isBye || b.isLegBye) return Colors.blueGrey;
    if (b.runs == 4) return Colors.blue;
    if (b.runs == 6) return Colors.purple;
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final battingTeamName = MatchService.isSecondInnings
        ? MatchService.teamBName
        : MatchService.teamAName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${MatchService.teamAName} vs ${MatchService.teamBName}",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _busy ? null : _undo,
            icon: const Icon(Icons.undo),
            tooltip: "Undo Last Ball",
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _scoreCard(battingTeamName),
              const SizedBox(height: 14),
              if (MatchService.isSecondInnings) _targetCard(),
              if (MatchService.isSecondInnings) const SizedBox(height: 14),
              _batsmenCard(),
              const SizedBox(height: 14),
              _bowlerCard(),
              const SizedBox(height: 14),
              _thisOverRow(),
              const SizedBox(height: 20),
              _runButtons(),
              const SizedBox(height: 14),
              _extrasButtons(),
              const SizedBox(height: 14),
              _wicketButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreCard(String battingTeamName) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              battingTeamName,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              "${MatchService.totalRuns} / ${MatchService.wickets}",
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Overs: $_oversText / ${MatchService.totalOvers}   "
              "CRR: ${MatchService.getCurrentRunRate().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _targetCard() {
    return Card(
      color: Colors.deepOrange.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Target: ${MatchService.target}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Need ${MatchService.getRemainingRuns()} runs "
              "off ${MatchService.getRemainingBalls()} balls   "
              "RRR: ${MatchService.getRequiredRunRate().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _batsmenCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _batsmanRow(MatchService.striker, onStrike: true),
            const SizedBox(height: 10),
            _batsmanRow(MatchService.nonStriker, onStrike: false),
          ],
        ),
      ),
    );
  }

  Widget _batsmanRow(PlayerModel? player, {required bool onStrike}) {
    return Row(
      children: [
        if (onStrike)
          const Icon(Icons.sports_cricket, size: 18, color: Colors.green)
        else
          const SizedBox(width: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            player?.name ?? "-",
            style: TextStyle(
              fontSize: 16,
              fontWeight: onStrike ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          player == null
              ? ""
              : "${player.runs} (${player.balls})",
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _bowlerCard() {
    final bowler = MatchService.currentBowler;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.sports_baseball, size: 18, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                bowler?.name ?? "-",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              bowler == null
                  ? ""
                  : "${bowler.wickets}-${bowler.runsGiven} "
                        "(${(bowler.ballsBowled / 6).floor()}."
                        "${bowler.ballsBowled % 6})",
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thisOverRow() {
    if (MatchService.thisOverBalls.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MatchService.thisOverBalls.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final b = MatchService.thisOverBalls[index];
          return CircleAvatar(
            radius: 18,
            backgroundColor: _ballColor(b),
            child: Text(
              _ballLabel(b),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _runButtons() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [0, 1, 2, 3, 4, 5, 6].map((r) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: r == 4
                ? Colors.blue
                : (r == 6 ? Colors.purple : null),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _addRun(r),
          child: Text(
            "$r",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  Widget _extrasButtons() {
    return Row(
      children: [
        Expanded(child: _extraButton("WD", _showWideDialog)),
        const SizedBox(width: 8),
        Expanded(child: _extraButton("NB", _showNoBallDialog)),
        const SizedBox(width: 8),
        Expanded(child: _extraButton("BYE", () => _showByeDialog(false))),
        const SizedBox(width: 8),
        Expanded(child: _extraButton("LB", () => _showByeDialog(true))),
      ],
    );
  }

  Widget _extraButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }

  Widget _wicketButton() {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _showWicketDialog,
        child: const Text(
          "WICKET",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
