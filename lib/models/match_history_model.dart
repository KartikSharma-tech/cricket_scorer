import 'package:hive/hive.dart';

part 'match_history_model.g.dart';

@HiveType(typeId: 1)
class MatchHistoryModel {

  // =========================
  // TEAM INFO
  // =========================

  @HiveField(0)
  String teamAName;

  @HiveField(1)
  String teamBName;

  // =========================
  // SCORE
  // =========================

  @HiveField(2)
  int teamAScore;

  @HiveField(3)
  int teamAWickets;

  @HiveField(4)
  int teamBScore;

  @HiveField(5)
  int teamBWickets;

  // =========================
  // MATCH INFO
  // =========================

  @HiveField(6)
  int overs;

  @HiveField(7)
  String result;

  @HiveField(8)
  String winner;

  // =========================
  // DATE
  // =========================

  @HiveField(9)
  DateTime matchDate;

  MatchHistoryModel({

    required this.teamAName,

    required this.teamBName,

    required this.teamAScore,

    required this.teamAWickets,

    required this.teamBScore,

    required this.teamBWickets,

    required this.overs,

    required this.result,

    required this.winner,

    required this.matchDate,
  });
}