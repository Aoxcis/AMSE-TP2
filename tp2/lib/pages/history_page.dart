import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text('Historique des parties'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'En cours'),
            Tab(text: 'Terminés'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGameGridView(false),
          _buildGameGridView(true),
        ],
      ),
    );
  }

  Widget _buildGameGridView(bool status) {
    return FutureBuilder<List<int>>(
      future: _loadGameIds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final gameIds = snapshot.data!;
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
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
                final gameData = snapshot.data!;
                final gameStatus = gameData['current']['isCompleted'];
                if (gameStatus != status) {
                  return const SizedBox.shrink();
                }
                return Card(
                  child: Column(
                    children: [
                      Text('Game $gameId'),
                      // Add more game details here
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<int>> _loadGameIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('game-ids') ?? [];
    return ids.map(int.parse).toList();
  }
}
