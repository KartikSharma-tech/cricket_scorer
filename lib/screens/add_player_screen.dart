import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../services/player_service.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {

  final TextEditingController nameController =
      TextEditingController();

  List<PlayerModel> players = [];

  @override
  void initState() {
    super.initState();

    loadPlayers();
  }

  // LOAD PLAYERS
  void loadPlayers() {

    players = PlayerService.getPlayers();

    setState(() {});
  }

  // ADD PLAYER
  Future<void> addPlayer() async {

    String name =
        nameController.text.trim();

    if(name.isEmpty){
      return;
    }

    // CHECK DUPLICATE
    bool alreadyExists = players.any(
      (player) {

        return player.name
            .toLowerCase() ==
            name.toLowerCase();
      },
    );

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

    await PlayerService.addPlayer(name);

    nameController.clear();

    loadPlayers();
  }

  // DELETE PLAYER
  Future<void> deletePlayer(
    int index,
  ) async {

    await PlayerService.deletePlayer(
      index,
    );

    loadPlayers();
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

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            // TEXTFIELD
            TextField(
              controller: nameController,

              decoration: InputDecoration(

                hintText: "Enter player name",

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),

                suffixIcon: IconButton(

                  onPressed: addPlayer,

                  icon: const Icon(
                    Icons.add,
                  ),
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
                ),
              )

                  : ListView.builder(

                itemCount: players.length,

                itemBuilder: (
                    context,
                    index,
                    ){

                  final player =
                  players[index];

                  return Card(

                    child: ListTile(

                      leading: CircleAvatar(
                        child: Text(
                          player.name[0]
                              .toUpperCase(),
                        ),
                      ),

                      title: Text(
                        player.name,
                      ),

                      subtitle: Text(
                        player.role,
                      ),

                      trailing: IconButton(

                        onPressed: () {

                          deletePlayer(
                            index,
                          );
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