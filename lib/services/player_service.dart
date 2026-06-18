import 'dart:math';

import '../models/player_model.dart';
import 'hive_service.dart';

class PlayerService {

  // ADD PLAYER
  static Future<void> addPlayer(
    String name,
  ) async {

    final player = PlayerModel(
      id: Random().nextInt(999999).toString(),
      name: name,
    );

    await HiveService.addPlayer(player);
  }

  // GET ALL PLAYERS
  static List<PlayerModel> getPlayers() {

    return HiveService.getAllPlayers();
  }

  // DELETE PLAYER
  static Future<void> deletePlayer(
    int index,
  ) async {

    await HiveService.deletePlayer(index);
  }
}