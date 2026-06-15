class PlayerModel {

  // =========================
  // PLAYER NAME
  // =========================

  String name;

  // =========================
  // BATTING STATS
  // =========================

  int runs;

  int balls;

  // =========================
  // BOWLING STATS
  // =========================

  int runsGiven;

  int ballsBowled;

  int wickets;

  // =========================
  // CONSTRUCTOR
  // =========================

  PlayerModel({

    required this.name,

    this.runs = 0,

    this.balls = 0,

    this.runsGiven = 0,

    this.ballsBowled = 0,

    this.wickets = 0,
  });

  // =========================
  // RESET PLAYER STATS
  // =========================

  void resetStats(){

    runs = 0;

    balls = 0;

    runsGiven = 0;

    ballsBowled = 0;

    wickets = 0;
  }
}
