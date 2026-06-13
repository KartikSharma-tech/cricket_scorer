import 'package:flutter/material.dart';
import '../models/player_model.dart';
import '../services/player_service.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final TextEditingController playerController = TextEditingController();

  List<PlayerModel> players = PlayerService.allPlayers;

  void addPlayer() {
    if (playerController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      players.add(PlayerModel(name: playerController.text.trim()));
    });

    playerController.clear();
  }

  void deletePlayer(int index) {
    setState(() {
      players.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Players")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: playerController,

              decoration: InputDecoration(
                hintText: "Enter player name",

                filled: true,
                fillColor: const Color(0xff1E293B),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),

                suffixIcon: IconButton(
                  onPressed: addPlayer,
                  icon: const Icon(Icons.add),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: players.isEmpty
                  ? const Center(
                      child: Text(
                        "No Players Added",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: players.length,

                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),

                          decoration: BoxDecoration(
                            color: const Color(0xff1E293B),
                            borderRadius: BorderRadius.circular(18),
                          ),

                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Text(players[index].name[0].toUpperCase()),
                            ),

                            title: Text(
                              players[index].name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            trailing: IconButton(
                              onPressed: () {
                                deletePlayer(index);
                              },

                              icon: const Icon(Icons.delete, color: Colors.red),
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
