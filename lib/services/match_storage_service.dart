import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';
import 'match_service.dart';

class MatchStorageService {

  // =========================
  // SAVE MATCH
  // =========================

  static Future saveMatch() async {

    SharedPreferences prefs =
    await SharedPreferences.getInstance();

    // TEAM INFO

    await prefs.setString(
      "teamAName",
      MatchService.teamAName,
    );

    await prefs.setString(
      "teamBName",
      MatchService.teamBName,
    );

    await prefs.setInt(
      "totalOvers",
      MatchService.totalOvers,
    );

    // SCORE

    await prefs.setInt(
      "totalRuns",
      MatchService.totalRuns,
    );

    await prefs.setInt(
      "wickets",
      MatchService.wickets,
    );

    await prefs.setInt(
      "over",
      MatchService.over,
    );

    await prefs.setInt(
      "ball",
      MatchService.ball,
    );

    // MATCH STATUS

    await prefs.setBool(
      "isSecondInnings",
      MatchService.isSecondInnings,
    );

    await prefs.setBool(
      "isMatchEnded",
      MatchService.isMatchEnded,
    );

    await prefs.setInt(
      "target",
      MatchService.target,
    );

    // PLAYERS

    await prefs.setString(
      "striker",
      MatchService.striker?.name ?? "",
    );

    await prefs.setString(
      "nonStriker",
      MatchService.nonStriker?.name ?? "",
    );

    await prefs.setString(
      "bowler",
      MatchService.currentBowler?.name ?? "",
    );

    // BATTING PLAYERS

    List<String> battingPlayers =

    MatchService.battingPlayers.map((player){

      return jsonEncode({

        "name": player.name,

        "runs": player.runs,

        "balls": player.balls,

        "runsGiven":
        player.runsGiven,

        "ballsBowled":
        player.ballsBowled,

        "wickets":
        player.wickets,
      });

    }).toList();

    await prefs.setStringList(
      "battingPlayers",
      battingPlayers,
    );

    // BOWLING PLAYERS

    List<String> bowlingPlayers =

    MatchService.bowlingPlayers.map((player){

      return jsonEncode({

        "name": player.name,

        "runs": player.runs,

        "balls": player.balls,

        "runsGiven":
        player.runsGiven,

        "ballsBowled":
        player.ballsBowled,

        "wickets":
        player.wickets,
      });

    }).toList();

    await prefs.setStringList(
      "bowlingPlayers",
      bowlingPlayers,
    );
  }

  // =========================
  // LOAD MATCH
  // =========================

  static Future<bool> loadMatch() async {

    SharedPreferences prefs =
    await SharedPreferences.getInstance();

    String? teamAName =
    prefs.getString("teamAName");

    if(teamAName == null){

      return false;
    }

    // TEAM INFO

    MatchService.teamAName =
        teamAName;

    MatchService.teamBName =
        prefs.getString(
          "teamBName",
        ) ?? "";

    MatchService.totalOvers =
        prefs.getInt(
          "totalOvers",
        ) ?? 0;

    // SCORE

    MatchService.totalRuns =
        prefs.getInt(
          "totalRuns",
        ) ?? 0;

    MatchService.wickets =
        prefs.getInt(
          "wickets",
        ) ?? 0;

    MatchService.over =
        prefs.getInt(
          "over",
        ) ?? 0;

    MatchService.ball =
        prefs.getInt(
          "ball",
        ) ?? 0;

    // STATUS

    MatchService.isSecondInnings =
        prefs.getBool(
          "isSecondInnings",
        ) ?? false;

    MatchService.isMatchEnded =
        prefs.getBool(
          "isMatchEnded",
        ) ?? false;

    MatchService.target =
        prefs.getInt(
          "target",
        ) ?? 0;

    // PLAYERS

    List<String> battingPlayersData =

    prefs.getStringList(
      "battingPlayers",
    ) ?? [];

    List<String> bowlingPlayersData =

    prefs.getStringList(
      "bowlingPlayers",
    ) ?? [];

    MatchService.battingPlayers =

    battingPlayersData.map((player){

      Map<String, dynamic> data =

      jsonDecode(player);

      return PlayerModel(

  id: DateTime.now()
      .millisecondsSinceEpoch
      .toString(),

  name: data["name"],

  runs: data["runs"],

  balls: data["balls"],

  runsGiven:
  data["runsGiven"],

  ballsBowled:
  data["ballsBowled"],

  wickets:
  data["wickets"],
);

    }).toList();

    MatchService.bowlingPlayers =

    bowlingPlayersData.map((player){

      Map<String, dynamic> data =

      jsonDecode(player);

      return PlayerModel(

  id: DateTime.now()
      .millisecondsSinceEpoch
      .toString(),

  name: data["name"],

  runs: data["runs"],

  balls: data["balls"],

  runsGiven:
  data["runsGiven"],

  ballsBowled:
  data["ballsBowled"],

  wickets:
  data["wickets"],
);

    }).toList();

    // STRIKER

    String strikerName =
    prefs.getString(
      "striker",
    ) ?? "";

    String nonStrikerName =
    prefs.getString(
      "nonStriker",
    ) ?? "";

    String bowlerName =
    prefs.getString(
      "bowler",
    ) ?? "";

    MatchService.striker =

    MatchService.battingPlayers
        .firstWhere(
          (player) =>
      player.name ==
          strikerName,
    );

    MatchService.nonStriker =

    MatchService.battingPlayers
        .firstWhere(
          (player) =>
      player.name ==
          nonStrikerName,
    );

    MatchService.currentBowler =

    MatchService.bowlingPlayers
        .firstWhere(
          (player) =>
      player.name ==
          bowlerName,
    );

    return true;
  }

  // =========================
  // CLEAR MATCH
  // =========================

  static Future clearMatch() async {

    SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(
      "teamAName",
    );

    await prefs.remove(
      "teamBName",
    );

    await prefs.remove(
      "totalOvers",
    );

    await prefs.remove(
      "totalRuns",
    );

    await prefs.remove(
      "wickets",
    );

    await prefs.remove(
      "over",
    );

    await prefs.remove(
      "ball",
    );

    await prefs.remove(
      "isSecondInnings",
    );

    await prefs.remove(
      "isMatchEnded",
    );

    await prefs.remove(
      "target",
    );

    await prefs.remove(
      "striker",
    );

    await prefs.remove(
      "nonStriker",
    );

    await prefs.remove(
      "bowler",
    );

    await prefs.remove(
      "battingPlayers",
    );

    await prefs.remove(
      "bowlingPlayers",
    );
  }
}