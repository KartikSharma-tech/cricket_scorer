import 'package:hive_flutter/hive_flutter.dart';

import '../models/player_model.dart';
import '../utils/app_constants.dart';
import '../models/match_history_model.dart';
class HiveService {

  // OPEN BOXES
  static Future<void> openBoxes() async {

  Hive.registerAdapter(
    PlayerModelAdapter(),
  );

  Hive.registerAdapter(
    MatchHistoryModelAdapter(),
  );

  await Hive.openBox<PlayerModel>(
    AppConstants.playersBox,
  );

  await Hive.openBox<MatchHistoryModel>(
    AppConstants.historyBox,
  );
}

  // PLAYER BOX
  static Box<PlayerModel> getPlayersBox() {

    return Hive.box<PlayerModel>(
      AppConstants.playersBox,
    );
  }
// HISTORY BOX
static Box<MatchHistoryModel>
getHistoryBox(){

  return Hive.box<MatchHistoryModel>(
    AppConstants.historyBox,
  );
}

// SAVE MATCH HISTORY
static Future<void>
saveMatchHistory(
    MatchHistoryModel match,
    ) async {

  final box = getHistoryBox();

  await box.add(match);
}

// GET MATCH HISTORY
static List<MatchHistoryModel>
getMatchHistory(){

  final box = getHistoryBox();

  return box.values.toList()
      .reversed
      .toList();
}
  // ADD PLAYER
  static Future<void> addPlayer(
    PlayerModel player,
  ) async {

    final box = getPlayersBox();

    await box.add(player);
  }

  // GET PLAYERS
  static List<PlayerModel> getAllPlayers() {

    final box = getPlayersBox();

    return box.values.toList();
  }

  // DELETE PLAYER
  static Future<void> deletePlayer(
    int index,
  ) async {

    final box = getPlayersBox();

    await box.deleteAt(index);
  }
}