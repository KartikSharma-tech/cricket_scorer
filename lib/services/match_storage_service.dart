import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';
import 'match_service.dart';

class MatchStorageService {
  // =========================
  // SAVE MATCH
  // =========================

  static Future<void> saveMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // TEAM INFO

    await prefs.setString("teamAName", MatchService.teamAName);

    await prefs.setString("teamBName", MatchService.teamBName);

    await prefs.setInt("totalOvers", MatchService.totalOvers);

    // SCORE

    await prefs.setInt("totalRuns", MatchService.totalRuns);

    await prefs.setInt("wickets", MatchService.wickets);

    await prefs.setInt("over", MatchService.over);

    await prefs.setInt("ball", MatchService.ball);

    // EXTRAS

    await prefs.setInt("wides", MatchService.wides);

    await prefs.setInt("noBalls", MatchService.noBalls);

    await prefs.setInt("byes", MatchService.byes);

    await prefs.setInt("legByes", MatchService.legByes);

    // MATCH STATUS

    await prefs.setBool("isSecondInnings", MatchService.isSecondInnings);

    await prefs.setBool("isMatchEnded", MatchService.isMatchEnded);

    await prefs.setInt("firstInningsScore", MatchService.firstInningsScore);

    await prefs.setInt("target", MatchService.target);

    await prefs.setString("resultText", MatchService.resultText);

    // CURRENT PLAYERS

    await prefs.setString("striker", MatchService.striker?.id ?? "");

    await prefs.setString("nonStriker", MatchService.nonStriker?.id ?? "");

    await prefs.setString(
      "currentBowler",

      MatchService.currentBowler?.id ?? "",
    );

    // OUT PLAYERS

    List<String> outPlayers = MatchService.outPlayers.map((player) {
      return player.id;
    }).toList();

    await prefs.setStringList("outPlayers", outPlayers);

    // BATTING PLAYERS

    List<String> battingPlayers = MatchService.battingPlayers.map((player) {
      return jsonEncode({
        "id": player.id,

        "name": player.name,

        "role": player.role,

        "runs": player.runs,

        "balls": player.balls,

        "wickets": player.wickets,

        "runsGiven": player.runsGiven,

        "ballsBowled": player.ballsBowled,

        "matches": player.matches,
      });
    }).toList();

    await prefs.setStringList("battingPlayers", battingPlayers);

    // BOWLING PLAYERS

    List<String> bowlingPlayers = MatchService.bowlingPlayers.map((player) {
      return jsonEncode({
        "id": player.id,

        "name": player.name,

        "role": player.role,

        "runs": player.runs,

        "balls": player.balls,

        "wickets": player.wickets,

        "runsGiven": player.runsGiven,

        "ballsBowled": player.ballsBowled,

        "matches": player.matches,
      });
    }).toList();

    await prefs.setStringList("bowlingPlayers", bowlingPlayers);
  }

  // =========================
  // LOAD MATCH
  // =========================

  static Future<bool> loadMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? teamAName = prefs.getString("teamAName");

    if (teamAName == null) {
      return false;
    }

    // TEAM INFO

    MatchService.teamAName = teamAName;

    MatchService.teamBName = prefs.getString("teamBName") ?? "";

    MatchService.totalOvers = prefs.getInt("totalOvers") ?? 0;

    // SCORE

    MatchService.totalRuns = prefs.getInt("totalRuns") ?? 0;

    MatchService.wickets = prefs.getInt("wickets") ?? 0;

    MatchService.over = prefs.getInt("over") ?? 0;

    MatchService.ball = prefs.getInt("ball") ?? 0;

    // EXTRAS

    MatchService.wides = prefs.getInt("wides") ?? 0;

    MatchService.noBalls = prefs.getInt("noBalls") ?? 0;

    MatchService.byes = prefs.getInt("byes") ?? 0;

    MatchService.legByes = prefs.getInt("legByes") ?? 0;

    // MATCH STATUS

    MatchService.isSecondInnings = prefs.getBool("isSecondInnings") ?? false;

    MatchService.isMatchEnded = prefs.getBool("isMatchEnded") ?? false;

    MatchService.firstInningsScore = prefs.getInt("firstInningsScore") ?? 0;

    MatchService.target = prefs.getInt("target") ?? 0;

    MatchService.resultText = prefs.getString("resultText") ?? "";

    // PLAYERS

    List<String> battingPlayersData =
        prefs.getStringList("battingPlayers") ?? [];

    List<String> bowlingPlayersData =
        prefs.getStringList("bowlingPlayers") ?? [];

    // BATTING PLAYERS

    MatchService.battingPlayers = battingPlayersData.map((player) {
      Map<String, dynamic> data = jsonDecode(player);

      return PlayerModel(
        id: data["id"],

        name: data["name"],

        role: data["role"],

        runs: data["runs"],

        balls: data["balls"],

        wickets: data["wickets"],

        runsGiven: data["runsGiven"],

        ballsBowled: data["ballsBowled"],

        matches: data["matches"],
      );
    }).toList();

    // BOWLING PLAYERS

    MatchService.bowlingPlayers = bowlingPlayersData.map((player) {
      Map<String, dynamic> data = jsonDecode(player);

      return PlayerModel(
        id: data["id"],

        name: data["name"],

        role: data["role"],

        runs: data["runs"],

        balls: data["balls"],

        wickets: data["wickets"],

        runsGiven: data["runsGiven"],

        ballsBowled: data["ballsBowled"],

        matches: data["matches"],
      );
    }).toList();

    // CURRENT PLAYER IDS

    String strikerId = prefs.getString("striker") ?? "";

    String nonStrikerId = prefs.getString("nonStriker") ?? "";

    String bowlerId = prefs.getString("currentBowler") ?? "";

    // STRIKER

   MatchService.striker = MatchService.battingPlayers.where((player) {
  return player.id == strikerId;
}).isNotEmpty
    ? MatchService.battingPlayers.firstWhere(
        (player) => player.id == strikerId,
      )
    : (MatchService.battingPlayers.isNotEmpty
        ? MatchService.battingPlayers.first
        : null);

    // NON STRIKER

    MatchService.nonStriker = MatchService.battingPlayers.where((player) {
  return player.id == nonStrikerId;
}).isNotEmpty
    ? MatchService.battingPlayers.firstWhere(
        (player) => player.id == nonStrikerId,
      )
    : (MatchService.battingPlayers.length > 1
        ? MatchService.battingPlayers[1]
        : null);

    // BOWLER

   MatchService.currentBowler = MatchService.bowlingPlayers.where((player) {
  return player.id == bowlerId;
}).isNotEmpty
    ? MatchService.bowlingPlayers.firstWhere(
        (player) => player.id == bowlerId,
      )
    : (MatchService.bowlingPlayers.isNotEmpty
        ? MatchService.bowlingPlayers.first
        : null);

    // OUT PLAYERS

    List<String> outIds = prefs.getStringList("outPlayers") ?? [];

    MatchService.outPlayers = MatchService.battingPlayers.where((player) {
      return outIds.contains(player.id);
    }).toList();

    return true;
  }

  // =========================
  // CLEAR MATCH
  // =========================
// =========================
// HAS SAVED MATCH
// =========================

static Future<bool>
hasSavedMatch() async {

  SharedPreferences prefs =
  await SharedPreferences
      .getInstance();

  return prefs.containsKey(
    "teamAName",
  );
}
  static Future<void> clearMatch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> keys = [
      "teamAName",

      "teamBName",

      "totalOvers",

      "totalRuns",

      "wickets",

      "over",

      "ball",

      "wides",

      "noBalls",

      "byes",

      "legByes",

      "isSecondInnings",

      "isMatchEnded",

      "firstInningsScore",

      "target",

      "resultText",

      "striker",

      "nonStriker",

      "currentBowler",

      "outPlayers",

      "battingPlayers",

      "bowlingPlayers",
    ];

    for (String key in keys) {
      await prefs.remove(key);
    }
  }
}
