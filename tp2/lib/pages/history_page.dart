import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tp2/widgets/nav_bar.dart';
import '../services/storage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Historique des parties'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En cours'),
            Tab(text: 'Terminés'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, List<int>>>(
        future: _loadGameIds(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final gameIds = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildGameGridView(gameIds['ongoing']!),
              _buildGameGridView(gameIds['completed']!),
            ],
          );
        },
      ),
      bottomNavigationBar: MyNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildGameGridView(List<int> gameIds) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150.0,
        childAspectRatio: 1.0,
      ),
      itemCount: gameIds.length,
      itemBuilder: (context, index) {
        final gameId = gameIds[index];
        final StorageService storage = StorageService();
        return FutureBuilder<Map<String, dynamic>>(
          future: storage.loadGame(gameId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final gameData = snapshot.data!; // for later get the image
            return GestureDetector(
              onTap: () => _launchGame(gameId),
              child: Card(
                child: Column(
                  children: [
                    //TODO: display image
                    // Expanded(
                    //   child: Image.network(
                    //     gameData['settings']['image'],
                    //     fit: BoxFit.contain,
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FittedBox(
                        child: Text(
                          "Partie $gameId",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _launchGame(int gameId) {
    Navigator.pushNamed(context, '/game', arguments: {'gameId': gameId});
  }

  Future<Map<String, List<int>>> _loadGameIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('game-ids') ?? [];
    final ongoing = <int>[];
    final completed = <int>[];

    for (var id in ids) {
      final gameId = int.parse(id);
      final StorageService storage = StorageService();
      final gameData = await storage.loadGame(gameId);
      final gameStatus = gameData['current']['isCompleted'];
      if (gameStatus) {
        completed.add(gameId);
      } else {
        ongoing.add(gameId);
      }
    }

    return {
      'ongoing': ongoing,
      'completed': completed,
    };
  }
}
