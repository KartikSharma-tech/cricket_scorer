import 'dart:math';

import '../models/player_model.dart';
import 'hive_service.dart';

class PlayerService {

  // =========================
  // GET ALL PLAYERS
  // =========================

  static List<PlayerModel>
  getPlayers(){

    return HiveService
        .getAllPlayers();
  }

  // =========================
  // ADD PLAYER
  // =========================

  static Future<void>
  addPlayer(
      String name,
      ) async {

    final trimmedName =
    name.trim();

    if(trimmedName.isEmpty){
      return;
    }

    // DUPLICATE CHECK

    List<PlayerModel>
    players = getPlayers();

    bool alreadyExists =

    players.any((player){

      return player.name
          .toLowerCase() ==

          trimmedName
              .toLowerCase();
    });

    if(alreadyExists){
      return;
    }

    final player = PlayerModel(

      id: Random()
          .nextInt(999999999)
          .toString(),

      name: trimmedName,

      role: "Player",

      runs: 0,

      balls: 0,

      wickets: 0,

      runsGiven: 0,

      ballsBowled: 0,

      matches: 0,
    );

    await HiveService
        .addPlayer(player);
  }

  // =========================
  // DELETE PLAYER
  // =========================

  static Future<void>
  deletePlayer(
      int index,
      ) async {

    await HiveService
        .deletePlayer(index);
  }

  // =========================
  // SEARCH PLAYERS
  // =========================

  static List<PlayerModel>
  searchPlayers(
      String query,
      ){

    List<PlayerModel>
    players = getPlayers();

    return players.where((player){

      return player.name
          .toLowerCase()
          .contains(
        query.toLowerCase(),
      );

    }).toList();
  }

  // =========================
  // RESET PLAYER MATCH STATS
  // =========================

  static void
  resetPlayerStats(
      List<PlayerModel> players,
      ){

    for(

    PlayerModel player
    in players

    ){

      player.runs = 0;

      player.balls = 0;

      player.wickets = 0;

      player.runsGiven = 0;

      player.ballsBowled = 0;
    }
  }
}