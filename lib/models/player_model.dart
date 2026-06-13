class PlayerModel {

  String name;

  int runs;
  int balls;

  int runsGiven;
  int ballsBowled;

  PlayerModel({

    required this.name,

    this.runs = 0,
    this.balls = 0,

    this.runsGiven = 0,
    this.ballsBowled = 0,
  });
}