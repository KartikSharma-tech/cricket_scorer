class MatchModel {

  String id;

  String teamA;

  String teamB;

  int totalRuns;

  int wickets;

  int overs;

  int balls;

  int totalOvers;

  bool isCompleted;

  String result;

  MatchModel({

    required this.id,

    required this.teamA,

    required this.teamB,

    required this.totalRuns,

    required this.wickets,

    required this.overs,

    required this.balls,

    required this.totalOvers,

    this.isCompleted = false,

    this.result = "",
  });

  Map<String, dynamic> toJson(){

    return {

      "id": id,

      "teamA": teamA,

      "teamB": teamB,

      "totalRuns": totalRuns,

      "wickets": wickets,

      "overs": overs,

      "balls": balls,

      "totalOvers": totalOvers,

      "isCompleted": isCompleted,

      "result": result,
    };
  }

  factory MatchModel.fromJson(
      Map<String, dynamic> json){

    return MatchModel(

      id: json["id"],

      teamA: json["teamA"],

      teamB: json["teamB"],

      totalRuns: json["totalRuns"],

      wickets: json["wickets"],

      overs: json["overs"],

      balls: json["balls"],

      totalOvers: json["totalOvers"],

      isCompleted:
      json["isCompleted"],

      result: json["result"],
    );
  }
}