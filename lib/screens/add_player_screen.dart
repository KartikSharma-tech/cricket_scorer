import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/player_service.dart';
import '../services/storage_service.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() =>
      _AddPlayerScreenState();
}

class _AddPlayerScreenState
    extends State<AddPlayerScreen> {

  final TextEditingController
  playerController =
  TextEditingController();

  List<PlayerModel> players = [];

  @override
  void initState() {

    super.initState();

    loadPlayers();
  }

  // LOAD PLAYERS

  void loadPlayers() async {

    List<PlayerModel> loadedPlayers =

    await StorageService.loadPlayers();

    setState(() {

      players = loadedPlayers;

      PlayerService.allPlayers =
          loadedPlayers;
    });
  }

  // ADD PLAYER

  void addPlayer() async {

    String name =
    playerController.text.trim();

    if(name.isEmpty){
      return;
    }

    bool alreadyExists =

    players.any((player){

      return player.name
          .toLowerCase() ==

          name.toLowerCase();
    });

    if(alreadyExists){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Player already exists",
          ),
        ),
      );

      return;
    }

    PlayerModel newPlayer =
    PlayerModel(name: name);

    setState(() {

      players.add(newPlayer);

      PlayerService.allPlayers =
          players;
    });

    // SAVE PLAYERS

    await StorageService
        .savePlayers(players);

    playerController.clear();
  }

  // DELETE PLAYER

  void deletePlayer(int index) async {

    setState(() {

      players.removeAt(index);

      PlayerService.allPlayers =
          players;
    });

    await StorageService
        .savePlayers(players);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Add Players",
        ),
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          children: [

            // TEXTFIELD

            TextField(

              controller:
              playerController,

              decoration:
              InputDecoration(

                hintText:
                "Enter Player Name",

                filled: true,

                fillColor:
                const Color(
                  0xff1E293B,
                ),

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),

                  borderSide:
                  BorderSide.none,
                ),

                suffixIcon: IconButton(

                  onPressed: (){
                    addPlayer();
                  },

                  icon: const Icon(
                    Icons.add,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // PLAYERS LIST

            Expanded(

              child: players.isEmpty

                  ?

              const Center(

                child: Text(
                  "No Players Added",
                ),
              )

                  :

              ListView.builder(

                itemCount:
                players.length,

                itemBuilder:
                    (context, index){

                  PlayerModel player =
                  players[index];

                  return Container(

                    margin:
                    const EdgeInsets.only(
                      bottom: 15,
                    ),

                    decoration:
                    BoxDecoration(

                      color:
                      const Color(
                        0xff1E293B,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),

                    child: ListTile(

                      leading:
                      CircleAvatar(

                        backgroundColor:
                        Colors.green,

                        child: Text(

                          player.name[0]
                              .toUpperCase(),
                        ),
                      ),

                      title:
                      Text(player.name),

                      trailing:
                      IconButton(

                        onPressed: (){

                          deletePlayer(index);
                        },

                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
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