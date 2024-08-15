import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'card_comparison_screen.dart'; // Import the new screen

void main() {
  runApp(PokemonCardApp());
}

class PokemonCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokémon Card Viewer',
      theme: ThemeData(
        fontFamily: 'Pokeymon',
        primarySwatch: Colors.blue,
      ),
      home: PokemonCardList(),
    );
  }
}

class PokemonCardList extends StatefulWidget {
  @override
  _PokemonCardListState createState() => _PokemonCardListState();
}

class _PokemonCardListState extends State<PokemonCardList> {
  List<dynamic> pokemonCards = [];
  int page = 1; // Start at the first page
  bool isLoading = false;
  bool hasMore = true;
  int? selectedIndex; // Track the selected card index

  @override
  void initState() {
    super.initState();
    fetchPokemonCards();
  }

  Future<void> fetchPokemonCards() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final limit = 10; // Number of items per page
    final response = await http.get(
      Uri.parse('https://api.pokemontcg.io/v2/cards?page=$page&pageSize=$limit'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        pokemonCards.addAll(data['data'] ?? []);
        page++;
        isLoading = false;
        hasMore = (data['data'] as List).length == limit; // Check if there are more items
      });
    } else {
      // Handle error (e.g., show a message)
      throw Exception('Failed to load Pokémon cards');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon Cards'),
        actions: [
          IconButton(
            icon: Icon(Icons.compare_arrows),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CardComparisonScreen(
                    pokemonCards: pokemonCards,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: pokemonCards.isEmpty && isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: pokemonCards.length + 1,
              itemBuilder: (context, index) {
                if (index == pokemonCards.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: hasMore
                        ? ElevatedButton(
                            onPressed: fetchPokemonCards,
                            child: isLoading
                                ? CircularProgressIndicator()
                                : Text('Load More'),
                          )
                        : Text('No more cards to load'),
                  );
                }
                final card = pokemonCards[index];
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PokemonCardDetail(card: card),
                        ),
                      );
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade200, // Single solid background color
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Image.network(card['images']?['small'] ?? ''),
                      title: Text(
                        card['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white, // Text color is always white to contrast with the background
                        ),
                      ),
                      subtitle: Text(
                        card['set']?['name'] ?? 'Unknown Set',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70, // Subtitle color is always white70 to contrast with the background
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class PokemonCardDetail extends StatelessWidget {
  final dynamic card;

  PokemonCardDetail({required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card['name'] ?? 'Unknown'),
      ),
      body: Container(
        color: Colors.blueGrey.shade200, // Single solid background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(card['images']?['large'] ?? ''),
              SizedBox(height: 16),
              Text(
                card['name'] ?? 'Unknown',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'HP: ${card['hp'] ?? 'N/A'}',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'Type: ${card['types']?.join(', ') ?? 'N/A'}',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'Rarity: ${card['rarity'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 2),
              Text(
                card['flavorText'] ?? 'No flavor text available',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
