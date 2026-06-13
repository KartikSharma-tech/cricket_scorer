import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/player_service.dart';

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

  List<PlayerModel> players =
      PlayerService.allPlayers;

  void addPlayer(){

    String name =
    playerController.text.trim();

    // EMPTY CHECK

    if(name.isEmpty){

      ScaffoldMessenger.of(context)
          .showSnackBar(

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

    // ADD PLAYER

    setState(() {

      players.add(

        PlayerModel(
          name: name,
        ),
      );
    });

    playerController.clear();

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content: Text(
          "Player Added",
        ),
      ),
    );
  }

  void deletePlayer(int index){

    setState(() {

      players.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Players"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

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
                const Color(0xff1E293B),

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(18),

                  borderSide:
                  BorderSide.none,
                ),

                suffixIcon:

                IconButton(

                  onPressed: addPlayer,

                  icon: const Icon(
                    Icons.add,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // TOTAL PLAYERS

            Align(

              alignment:
              Alignment.centerLeft,

              child: Text(

                "Total Players: ${players.length}",

                style: const TextStyle(

                  fontSize: 18,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PLAYER LIST

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

                  return Container(

                    margin:
                    const EdgeInsets.only(
                      bottom: 15,
                    ),

                    decoration:
                    BoxDecoration(

                      color:
                      const Color(0xff1E293B),

                      borderRadius:
                      BorderRadius.circular(18),
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

                      title: Text(

                        player.name,

                        style:
                        const TextStyle(

                          fontSize: 18,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(

                        "Runs: ${player.runs}",

                        style:
                        const TextStyle(
                          color: Colors.grey,
                        ),
                      ),

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