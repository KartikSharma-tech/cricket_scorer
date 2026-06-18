import 'package:hive/hive.dart';

part 'player_model.g.dart';

@HiveType(typeId: 0)
class PlayerModel {

  // =========================
  // BASIC INFO
  // =========================

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String role;

  // =========================
  // BATTING STATS
  // =========================

  @HiveField(3)
  int runs;

  @HiveField(4)
  int balls;

  // =========================
  // BOWLING STATS
  // =========================

  @HiveField(5)
  int wickets;

  @HiveField(6)
  int runsGiven;

  @HiveField(7)
  int ballsBowled;

  // =========================
  // CAREER
  // =========================

  @HiveField(8)
  int matches;

  // =========================
  // CONSTRUCTOR
  // =========================

  PlayerModel({

    required this.id,

    required this.name,

    this.role = "Player",

    this.runs = 0,

    this.balls = 0,

    this.wickets = 0,

    this.runsGiven = 0,

    this.ballsBowled = 0,

    this.matches = 0,
  });

  // =========================
  // SIMPLE CONSTRUCTOR
  // =========================

  factory PlayerModel.simple({

    required String name,

  }) {

    return PlayerModel(

      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),

      name: name,
    );
  }
}