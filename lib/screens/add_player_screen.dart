import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/player_service.dart';

class AddPlayerScreen
    extends StatefulWidget {

  const AddPlayerScreen({
    super.key,
  });

  @override
  State<AddPlayerScreen>
  createState() =>

      _AddPlayerScreenState();
}

class _AddPlayerScreenState
    extends State<AddPlayerScreen> {

  // =========================
  // CONTROLLER
  // =========================

  final TextEditingController
  nameController =
  TextEditingController();

  // =========================
  // PLAYERS
  // =========================

  List<PlayerModel> players = [];

  // =========================
  // INIT
  // =========================

  @override
  void initState() {
    super.initState();

    loadPlayers();
  }

  // =========================
  // LOAD PLAYERS
  // =========================

  void loadPlayers(){

    players =
        PlayerService.getPlayers();

    setState(() {});
  }

  // =========================
  // ADD PLAYER
  // =========================

  Future<void>
  addPlayer() async {

    String name =
    nameController.text
        .trim();

    if(name.isEmpty){

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            "Enter player name",
          ),
        ),
      );

      return;
    }

    // DUPLICATE CHECK

    bool alreadyExists =

    players.any((player){

      return player.name
          .toLowerCase() ==

          name.toLowerCase();
    });

    if(alreadyExists){

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            "Player already exists",
          ),
        ),
      );

      return;
    }

    await PlayerService
        .addPlayer(name);

    nameController.clear();

    loadPlayers();
  }

  // =========================
  // DELETE PLAYER
  // =========================

  Future<void>
  deletePlayer(
      int index,
      ) async {

    await PlayerService
        .deletePlayer(index);

    loadPlayers();
  }

  // =========================
  // PLAYER CARD
  // =========================

  Widget playerCard(
      PlayerModel player,
      int index,
      ){

    return Card(

      elevation: 3,

      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(
          15,
        ),
      ),

      child: ListTile(

        contentPadding:
        const EdgeInsets.symmetric(

          horizontal: 16,
          vertical: 10,
        ),

        leading: CircleAvatar(

          radius: 25,

          backgroundColor:
          Colors.green,

          child: Text(

            player.name[0]
                .toUpperCase(),

            style: const TextStyle(

              color: Colors.white,

              fontWeight:
              FontWeight.bold,

              fontSize: 20,
            ),
          ),
        ),

        title: Text(

          player.name,

          style: const TextStyle(

            fontWeight:
            FontWeight.bold,

            fontSize: 18,
          ),
        ),

        subtitle: Text(
          player.role,
        ),

        trailing: IconButton(

          onPressed: () {

            deletePlayer(index);
          },

          icon: const Icon(

            Icons.delete,

            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Add Players",
        ),

        centerTitle: true,
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          children: [

            // =========================
            // INPUT
            // =========================

            Row(

              children: [

                Expanded(

                  child: TextField(

                    controller:
                    nameController,

                    decoration:
                    InputDecoration(

                      hintText:
                      "Enter player name",

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                SizedBox(

                  height: 60,

                  child: ElevatedButton(

                    style:
                    ElevatedButton
                        .styleFrom(

                      backgroundColor:
                      Colors.green,

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),

                    onPressed:
                    addPlayer,

                    child: const Text(

                      "Add",

                      style: TextStyle(

                        fontSize: 18,

                        color:
                        Colors.white,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 25,
            ),

            // =========================
            // TOTAL
            // =========================

            Align(

              alignment:
              Alignment.centerLeft,

              child: Text(

                "Total Players : ${players.length}",

                style: const TextStyle(

                  fontSize: 18,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // =========================
            // PLAYER LIST
            // =========================

            Expanded(

              child: players.isEmpty

                  ? const Center(

                child: Text(

                  "No Players Added",

                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              )

                  : ListView.builder(

                itemCount:
                players.length,

                itemBuilder:
                    (context, index){

                  PlayerModel player =
                  players[index];

                  return playerCard(
                    player,
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}