
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';

class StorageService {

  // =========================
  // SAVE PLAYERS
  // =========================

  static Future savePlayers(

      List<PlayerModel> players

      ) async {

    SharedPreferences prefs =

    await SharedPreferences
        .getInstance();

    List<String> playerList =

    players.map((player){

      return jsonEncode({

        "name": player.name,
      });

    }).toList();

    await prefs.setStringList(
      "players",
      playerList,
    );
  }

  // =========================
  // LOAD PLAYERS
  // =========================

  static Future<List<PlayerModel>>
  loadPlayers() async {

    SharedPreferences prefs =

    await SharedPreferences
        .getInstance();

    List<String>? playerList =

    prefs.getStringList(
      "players",
    );

    if(playerList == null){

      return [];
    }

    return playerList.map((player){

      Map<String, dynamic> data =

      jsonDecode(player);

      return PlayerModel(

  id: DateTime.now()
      .millisecondsSinceEpoch
      .toString(),

  name: data["name"],
);

    }).toList();
  }
}
