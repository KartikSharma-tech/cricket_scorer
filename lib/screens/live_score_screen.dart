import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/ball_model.dart';
import '../models/player_model.dart';
import '../services/match_service.dart';
import '../services/match_storage_service.dart';
import 'match_result_screen.dart';
import 'scorecard_screen.dart';

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
      'fallOfWickets': List.from(MatchService.fallOfWickets),
      'partnershipStartRuns': MatchService.partnershipStartRuns,
      'partnershipBallCount': MatchService.partnershipBallCount,
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
    MatchService.partnershipStartRuns = s['partnershipStartRuns'];
    MatchService.partnershipBallCount = s['partnershipBallCount'];
    MatchService.fallOfWickets = List<Map<String, dynamic>>.from(
      s['fallOfWickets'],
    );

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to undo'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    setState(() => _busy = true);

    _pushUndo();

    final striker = MatchService.striker!;
    striker.runs += runs;
    striker.balls += 1;

    MatchService.totalRuns += runs;
    MatchService.currentBowler!.runsGiven += runs;

    // Milestone check
    _checkMilestone(striker, runs);

    final ball = BallModel(
      id: _newId(),
      runs: runs,
      strikerId: striker.id,
      bowlerId: MatchService.currentBowler!.id,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    final overCompleted = MatchService.recordLegalBall();

    if (runs % 2 == 1) _rotateStrike();

    // Haptic feedback
    if (runs == 4) HapticFeedback.mediumImpact();
    if (runs == 6) HapticFeedback.heavyImpact();

    await _afterBall(overCompleted);
    setState(() => _busy = false);
  }

  Future<void> _addWide(int extra) async {
    if (_guardBlocked()) return;
    setState(() => _busy = true);

    _pushUndo();

    MatchService.totalRuns += 1 + extra;
    MatchService.wides += 1 + extra;
    MatchService.currentBowler!.runsGiven += 1 + extra;

    final ball = BallModel(
      id: _newId(),
      runs: 0,
      isWide: true,
      extraRuns: extra,
      bowlerId: MatchService.currentBowler!.id,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    if ((1 + extra) % 2 == 1) _rotateStrike();

    await _afterBall(false);
    setState(() => _busy = false);
  }

  Future<void> _addNoBall(int batRuns) async {
    if (_guardBlocked()) return;
    setState(() => _busy = true);

    _pushUndo();

    final striker = MatchService.striker!;
    striker.runs += batRuns;
    striker.balls += 1;
    MatchService.totalRuns += batRuns + 1;
    MatchService.noBalls += 1;
    MatchService.currentBowler!.runsGiven += batRuns + 1;

    final ball = BallModel(
      id: _newId(),
      runs: batRuns,
      isNoBall: true,
      strikerId: striker.id,
      bowlerId: MatchService.currentBowler!.id,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    if (batRuns % 2 == 1) _rotateStrike();

    await _afterBall(false);
    setState(() => _busy = false);
  }

  Future<void> _addExtraRun(int runs, {required bool isLegBye}) async {
    if (_guardBlocked()) return;
    setState(() => _busy = true);

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
      strikerId: MatchService.striker!.id,
      bowlerId: MatchService.currentBowler!.id,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    final overCompleted = MatchService.recordLegalBall();

    if (runs % 2 == 1) _rotateStrike();

    await _afterBall(overCompleted);
    setState(() => _busy = false);
  }

  Future<void> _addWicket(String type) async {
    if (_guardBlocked()) return;
    setState(() => _busy = true);

    _pushUndo();

    final out = MatchService.striker!;
    out.balls += 1;

    MatchService.wickets += 1;
    MatchService.currentBowler!.wickets += 1;
    MatchService.outPlayers.add(out);

    HapticFeedback.heavyImpact();

    final ball = BallModel(
      id: _newId(),
      runs: 0,
      isWicket: true,
      wicketType: type,
      outPlayerId: out.id,
      strikerId: out.id,
      bowlerId: MatchService.currentBowler!.id,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    MatchService.recordFallOfWicket(out.name);

    final overCompleted = MatchService.recordLegalBall();

    if (!MatchService.isLastManStanding) {
      MatchService.striker = null;
    }

    await _afterBall(overCompleted, wicketFell: true);
    setState(() => _busy = false);
  }

  Future<void> _addRunOut({
    required bool strikerIsOut,
    required int runsCompleted,
  }) async {
    if (_guardBlocked()) return;
    setState(() => _busy = true);

    _pushUndo();

    final striker = MatchService.striker!;
    striker.balls += 1;
    striker.runs += runsCompleted;

    MatchService.totalRuns += runsCompleted;
    MatchService.currentBowler!.runsGiven += runsCompleted;
    MatchService.wickets += 1;

    HapticFeedback.heavyImpact();

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
      strikerId: striker.id,
      bowlerId: MatchService.currentBowler!.id,
    );
    MatchService.ballHistory.add(ball);
    MatchService.thisOverBalls.add(ball);

    MatchService.recordFallOfWicket(outPlayer.name);

    final overCompleted = MatchService.recordLegalBall();

    if (strikerIsOut) {
      MatchService.striker = null;
    } else {
      MatchService.nonStriker = null;
    }

    await _afterBall(overCompleted, wicketFell: true);
    setState(() => _busy = false);
  }

  // =========================
  // MILESTONE CHECKER
  // =========================

  void _checkMilestone(PlayerModel striker, int runs) {
    final prev = striker.runs - runs;
    final curr = striker.runs;

    if (prev < 50 && curr >= 50 && curr < 100) {
      _showMilestoneSnack('🏏 ${striker.name} - FIFTY! 50 runs');
    } else if (prev < 100 && curr >= 100) {
      _showMilestoneSnack('💯 ${striker.name} - CENTURY! 100 runs');
      HapticFeedback.heavyImpact();
    }

    // 5-wicket haul
    if (MatchService.currentBowler != null &&
        MatchService.currentBowler!.wickets == 5) {
      _showMilestoneSnack(
          '🎳 ${MatchService.currentBowler!.name} - FIVE WICKET HAUL!');
    }
  }

  void _showMilestoneSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // =========================
  // GUARD
  // =========================

  bool _guardBlocked() {
    if (_busy) return true;
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

    // INNINGS OVER
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

    // TARGET CHASED DOWN (mid-over)
    if (MatchService.isSecondInnings && MatchService.targetAchieved) {
      MatchService.checkWinner();
      await MatchStorageService.saveMatch();
      if (MatchService.isMatchEnded && mounted) {
        _goToResult();
        return;
      }
    }

    // LAST MAN STANDING
    if (MatchService.isLastManStanding) {
      if (MatchService.striker == null) {
        MatchService.striker = MatchService.nonStriker;
      }
      MatchService.nonStriker = null;
      if (mounted) setState(() {});
    }

    // NEW BATSMAN if needed
    if (!MatchService.isLastManStanding &&
        (MatchService.striker == null || MatchService.nonStriker == null)) {
      await _pickNextBatsman();
    }

    // ROTATE STRIKE at end of over
    if (overCompleted && !MatchService.isLastManStanding) {
      _rotateStrike();
    }

    // NEW BOWLER every over — single call
    if (overCompleted) {
      MatchService.currentBowler = null;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.sports_cricket, color: Colors.orange),
            SizedBox(width: 8),
            Text('Innings Break'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inningsBreakRow(
              MatchService.firstBattingTeam,
              MatchService.totalRuns,
              MatchService.wickets,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              '${MatchService.secondBattingTeam} need '
              '${MatchService.totalRuns + 1} to win',
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Start 2nd Innings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    setState(() {
      MatchService.startSecondInnings();
    });

    _undoStack.clear();

    await MatchStorageService.saveMatch();

    await _pickNextBatsman();
    if (!mounted) return;
    await _pickNextBatsman();
    if (!mounted) return;
    await _pickNextBowler();

    if (mounted) setState(() {});
    await MatchStorageService.saveMatch();
  }

  Widget _inningsBreakRow(String team, int runs, int wkts) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(team, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          '$runs / $wkts',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
      ],
    );
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
      final isIn =
          p.id == MatchService.striker?.id ||
          p.id == MatchService.nonStriker?.id;
      return !isOut && !isIn;
    }).toList();

    if (available.isEmpty) return;

    final selected = await showDialog<PlayerModel>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.sports_cricket, size: 20, color: Colors.green),
            SizedBox(width: 8),
            Text('Next Batsman'),
          ],
        ),
        children: available.map((p) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, p),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(p.name, style: const TextStyle(fontSize: 16)),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.sports_baseball, size: 20, color: Colors.orange),
            SizedBox(width: 8),
            Text('Select Bowler'),
          ],
        ),
        children: available.map((p) {
          final overs = (p.ballsBowled / 6).floor();
          final balls = p.ballsBowled % 6;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, p),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.name, style: const TextStyle(fontSize: 16)),
                  Text(
                    '${p.wickets}-${p.runsGiven} ($overs.$balls)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.cancel, size: 20, color: Colors.red),
            SizedBox(width: 8),
            Text('How Out?'),
          ],
        ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(t, style: const TextStyle(fontSize: 16)),
            ),
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
      await _addRunOut(strikerIsOut: true, runsCompleted: 0);
      return;
    }

    final strikerOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Who's Run Out?"),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                MatchService.striker?.name ?? 'Striker',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                MatchService.nonStriker?.name ?? 'Non-Striker',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );

    if (strikerOut == null) return;

    final runs = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Runs Completed'),
        children: [0, 1, 2, 3].map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, r),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('$r runs', style: const TextStyle(fontSize: 16)),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Wide — Extra runs?'),
        children: [0, 1, 2, 3, 4].map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, r),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                r == 0 ? 'Wide only (+1)' : 'Wide + $r run(s)',
                style: const TextStyle(fontSize: 16),
              ),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('No Ball — Runs off bat?'),
        children: [0, 1, 2, 3, 4, 6].map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, r),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('$r', style: const TextStyle(fontSize: 16)),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(isLegBye ? 'Leg Byes' : 'Byes'),
        children: [1, 2, 3, 4].map((r) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, r),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('$r', style: const TextStyle(fontSize: 16)),
            ),
          );
        }).toList(),
      ),
    );

    if (runs != null) await _addExtraRun(runs, isLegBye: isLegBye);
  }

  // =========================
  // UI HELPERS
  // =========================

  String get _oversText => '${MatchService.over}.${MatchService.ball}';

  String _ballLabel(BallModel b) {
    if (b.isWicket) return 'W';
    if (b.isWide) return b.extraRuns > 0 ? 'Wd+${b.extraRuns}' : 'Wd';
    if (b.isNoBall) return 'Nb${b.runs > 0 ? '+${b.runs}' : ''}';
    if (b.isBye) return '${b.runs}B';
    if (b.isLegBye) return '${b.runs}Lb';
    return '${b.runs}';
  }

  Color _ballColor(BallModel b) {
    if (b.isWicket) return Colors.red;
    if (b.isWide || b.isNoBall) return Colors.orange;
    if (b.isBye || b.isLegBye) return Colors.blueGrey;
    if (b.runs == 4) return Colors.blue;
    if (b.runs == 6) return Colors.purple;
    return Colors.grey.shade700;
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    final battingTeamName = MatchService.isSecondInnings
        ? MatchService.secondBattingTeam
        : MatchService.firstBattingTeam;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text('Leave Match?'),
            content: const Text(
              'Match is in progress. Your progress is saved — you can resume later.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Stay'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Leave',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${MatchService.teamAName} vs ${MatchService.teamBName}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ScorecardScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt),
              tooltip: 'Scorecard',
            ),
            IconButton(
              onPressed: _busy ? null : _undo,
              icon: const Icon(Icons.undo),
              tooltip: 'Undo Last Ball',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SCORE CARD
                _scoreCard(battingTeamName),
                const SizedBox(height: 10),

                // TARGET CARD (2nd innings only)
                if (MatchService.isSecondInnings) ...[
                  _targetCard(),
                  const SizedBox(height: 10),
                ],

                // BATSMEN + BOWLER ROW
                Row(
                  children: [
                    Expanded(child: _batsmenCard()),
                    const SizedBox(width: 10),
                    _bowlerCard(),
                  ],
                ),
                const SizedBox(height: 8),

                // PARTNERSHIP + THIS OVER ROW
                _partnershipAndOverRow(),
                const SizedBox(height: 18),

                // DIVIDER
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'SCORING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 14),

                // RUN BUTTONS
                _runButtons(),
                const SizedBox(height: 12),

                // EXTRAS ROW
                _extrasButtons(),
                const SizedBox(height: 12),

                // WICKET BUTTON
                _wicketButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // SCORE CARD WIDGET
  // =========================

  Widget _scoreCard(String battingTeamName) {
    final inningsLabel = MatchService.isSecondInnings
        ? '2nd Innings'
        : '1st Innings';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1D4ED8), Color(0xff7C3AED)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D4ED8).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team name + innings badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    battingTeamName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    inningsLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Big score
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${MatchService.totalRuns}',
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '/ ${MatchService.wickets}',
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Overs + CRR + Extras
            Row(
              children: [
                _scoreChip(
                  'Overs',
                  '$_oversText / ${MatchService.totalOvers}',
                ),
                const SizedBox(width: 10),
                _scoreChip(
                  'CRR',
                  MatchService.getCurrentRunRate().toStringAsFixed(2),
                ),
                const SizedBox(width: 10),
                _scoreChip(
                  'Extras',
                  '${MatchService.getTotalExtras()}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white60),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // TARGET CARD
  // =========================

  Widget _targetCard() {
    final remaining = MatchService.getRemainingRuns();
    final balls = MatchService.getRemainingBalls();
    final rrr = MatchService.getRequiredRunRate();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.deepOrange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target ${MatchService.target}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Need $remaining off $balls balls',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Text(
                  'RRR',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
                Text(
                  rrr.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // BATSMEN CARD
  // =========================

  Widget _batsmenCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _batsmanRow(MatchService.striker, onStrike: true),
          const SizedBox(height: 8),
          _batsmanRow(MatchService.nonStriker, onStrike: false),
        ],
      ),
    );
  }

  Widget _batsmanRow(PlayerModel? player, {required bool onStrike}) {
    final sr = player != null && player.balls > 0
        ? (player.runs / player.balls * 100).toStringAsFixed(0)
        : '-';

    return Row(
      children: [
        SizedBox(
          width: 18,
          child: onStrike
              ? const Icon(Icons.sports_cricket, size: 14, color: Colors.green)
              : null,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            player?.name ?? '-',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: onStrike ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (player != null) ...[
          Text(
            '${player.runs}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: onStrike
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          ),
          Text(
            ' (${player.balls})',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(width: 4),
          Text(
            'SR $sr',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  // =========================
  // BOWLER CARD
  // =========================

  Widget _bowlerCard() {
    final bowler = MatchService.currentBowler;
    final overs = bowler != null
        ? '${(bowler.ballsBowled / 6).floor()}.${bowler.ballsBowled % 6}'
        : '-';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_baseball, size: 13, color: Colors.orange),
              const SizedBox(width: 4),
              const Text(
                'Bowling',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            bowler?.name ?? '-',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          if (bowler != null) ...[
            const SizedBox(height: 2),
            Text(
              '${bowler.wickets}-${bowler.runsGiven} ($overs)',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // PARTNERSHIP + THIS OVER
  // =========================

  Widget _partnershipAndOverRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Partnership
        if (MatchService.striker != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Partnership',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${MatchService.partnershipRuns} (${MatchService.partnershipBalls} b)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (MatchService.thisOverBalls.isNotEmpty) ...[
          const SizedBox(width: 10),

          // This Over
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Over ${MatchService.over + 1}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: MatchService.thisOverBalls.map((b) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: _ballColor(b),
                            child: Text(
                              _ballLabel(b),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // =========================
  // RUN BUTTONS
  // =========================

  Widget _runButtons() {
    // Row 1: 1 2 3 4 6
    // Row 2: 0 (dot) — full width separate style
    return Column(
      children: [
        Row(
          children: [1, 2, 3, 4, 6].map((r) {
            Color? bg;
            if (r == 4) bg = Colors.blue;
            if (r == 6) bg = Colors.purple;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: r == 4 || r == 6 ? 3 : 1,
                    ),
                    onPressed: _busy ? null : () => _addRun(r),
                    child: Text(
                      '$r',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            onPressed: _busy ? null : () => _addRun(0),
            child: Text(
              'DOT  •  0',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // EXTRAS BUTTONS
  // =========================

  Widget _extrasButtons() {
    return Row(
      children: [
        Expanded(child: _extraButton('WD', _showWideDialog, Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _extraButton('NB', _showNoBallDialog, Colors.orange.shade800)),
        const SizedBox(width: 8),
        Expanded(child: _extraButton('BYE', () => _showByeDialog(false), Colors.teal)),
        const SizedBox(width: 8),
        Expanded(child: _extraButton('LB', () => _showByeDialog(true), Colors.teal.shade700)),
      ],
    );
  }

  Widget _extraButton(String label, VoidCallback onTap, Color color) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _busy ? null : onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // =========================
  // WICKET BUTTON
  // =========================

  Widget _wicketButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
        onPressed: _busy ? null : _showWicketDialog,
        icon: const Icon(Icons.cancel, color: Colors.white),
        label: const Text(
          'WICKET',
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