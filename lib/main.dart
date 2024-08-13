import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './loading_screen.dart'; // Import the loading screen
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

List<Color> _getGradientColors(String rarity) {
  switch (rarity.toLowerCase()) {
    case 'amazing rare':
      return [Colors.deepPurple.shade200, Colors.blueAccent.shade200];
    case 'common':
      return [Colors.grey.shade300, Colors.blueGrey.shade200];
    case 'legend':
      return [Colors.cyan.shade200, Colors.deepPurple.shade200];
    case 'promo':
      return [Colors.orange.shade200, Colors.redAccent.shade200];
    case 'rare':
      return [Colors.blue.shade200, Colors.purple.shade200];
    case 'rare ace':
      return [Colors.indigo.shade200, Colors.teal.shade200];
    case 'rare break':
      return [Colors.green.shade200, Colors.yellow.shade200];
    case 'rare holo':
      return [Colors.blueGrey.shade200, Colors.teal.shade200];
    case 'rare holo ex':
      return [Colors.pink.shade200, Colors.purpleAccent.shade200];
    case 'rare holo gx':
      return [Colors.deepOrange.shade200, Colors.red.shade200];
    case 'rare holo lv.x':
      return [Colors.amber.shade200, Colors.orange.shade200];
    case 'rare holo star':
      return [Colors.yellow.shade200, Colors.deepOrange.shade200];
    case 'rare holo v':
      return [Colors.red.shade200, Colors.pink.shade200];
    case 'rare holo vmax':
      return [Colors.purple.shade200, Colors.deepPurpleAccent.shade200];
    case 'rare prime':
      return [Colors.blue.shade200, Colors.cyan.shade200];
    case 'rare prism star':
      return [Colors.pink.shade200, Colors.blue.shade200];
    case 'rare rainbow':
      return [Colors.red.shade200, Colors.orange.shade200, Colors.yellow.shade200, Colors.green.shade200, Colors.blue.shade200, Colors.indigo.shade200, Colors.purple.shade200];
    case 'rare secret':
      return [Colors.blueGrey.shade200, Colors.black54];
    case 'rare shining':
      return [Colors.pink.shade200, Colors.yellow.shade200];
    case 'rare shiny':
      return [Colors.red.shade200, Colors.orange.shade200];
    case 'rare shiny gx':
      return [Colors.purple.shade200, Colors.blueAccent.shade200];
    case 'rare ultra':
      return [Colors.green.shade200, Colors.blue.shade200];
    case 'uncommon':
      return [Colors.green.shade200, Colors.lightGreen.shade200];
    default:
      return [Colors.white, Colors.grey.shade200];
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon Cards'),
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
                final gradientColors = _getGradientColors(card['rarity'] ?? 'common');

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
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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
                          color: Colors.white, // Text color is always white to contrast with the gradient
                        ),
                      ),
                      subtitle: Text(
                        card['set']?['name'] ?? 'Unknown Set',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70, // Subtitle color is always white70 to contrast with the gradient
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

  List<Color> _getGradientColors(String rarity) {
  switch (rarity.toLowerCase()) {
    case 'amazing rare':
      return [Colors.deepPurple.shade200, Colors.blueAccent.shade200];
    case 'common':
      return [Colors.grey.shade300, Colors.blueGrey.shade200];
    case 'legend':
      return [Colors.cyan.shade200, Colors.deepPurple.shade200];
    case 'promo':
      return [Colors.orange.shade200, Colors.redAccent.shade200];
    case 'rare':
      return [Colors.blue.shade200, Colors.purple.shade200];
    case 'rare ace':
      return [Colors.indigo.shade200, Colors.teal.shade200];
    case 'rare break':
      return [Colors.green.shade200, Colors.yellow.shade200];
    case 'rare holo':
      return [Colors.blueGrey.shade200, Colors.teal.shade200];
    case 'rare holo ex':
      return [Colors.pink.shade200, Colors.purpleAccent.shade200];
    case 'rare holo gx':
      return [Colors.deepOrange.shade200, Colors.red.shade200];
    case 'rare holo lv.x':
      return [Colors.amber.shade200, Colors.orange.shade200];
    case 'rare holo star':
      return [Colors.yellow.shade200, Colors.deepOrange.shade200];
    case 'rare holo v':
      return [Colors.red.shade200, Colors.pink.shade200];
    case 'rare holo vmax':
      return [Colors.purple.shade200, Colors.deepPurpleAccent.shade200];
    case 'rare prime':
      return [Colors.blue.shade200, Colors.cyan.shade200];
    case 'rare prism star':
      return [Colors.pink.shade200, Colors.blue.shade200];
    case 'rare rainbow':
      return [Colors.red.shade200, Colors.orange.shade200, Colors.yellow.shade200, Colors.green.shade200, Colors.blue.shade200, Colors.indigo.shade200, Colors.purple.shade200];
    case 'rare secret':
      return [Colors.blueGrey.shade200, Colors.black54];
    case 'rare shining':
      return [Colors.pink.shade200, Colors.yellow.shade200];
    case 'rare shiny':
      return [Colors.red.shade200, Colors.orange.shade200];
    case 'rare shiny gx':
      return [Colors.purple.shade200, Colors.blueAccent.shade200];
    case 'rare ultra':
      return [Colors.green.shade200, Colors.blue.shade200];
    case 'uncommon':
      return [Colors.green.shade200, Colors.lightGreen.shade200];
    default:
      return [Colors.white, Colors.grey.shade200];
  }
}


  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors(card['rarity'] ?? 'common');

    return Scaffold(
      appBar: AppBar(
        title: Text(card['name'] ?? 'Unknown'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
