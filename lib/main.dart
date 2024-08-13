import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      Uri.parse(
          'https://api.pokemontcg.io/v2/cards?page=$page&pageSize=$limit'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        pokemonCards.addAll(data['data']);
        page++;
        isLoading = false;
        hasMore = data['data'].length ==
            limit; // If fewer than limit items are returned, no more pages
      });
    } else {
      throw Exception('Failed to load Pokémon cards');
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
                return ListTile(
                  leading: Image.network(card['images']['small']),
                  title: Text(
                    card['name'],
                    style: TextStyle(
                        fontSize: 20), // Increase the font size for the title
                  ),
                  subtitle: Text(
                    card['set']['name'],
                    style: TextStyle(
                        fontSize:
                            16), // Increase the font size for the subtitle
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonCardDetail(card: card),
                      ),
                    );
                  },
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
        title: Text(card['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.network(card['images']['large']),
            SizedBox(height: 2),
            Text(
              card['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              'HP: ${card['hp']}',
              style: TextStyle(fontSize: 24), // Increase font size for HP
            ),
            SizedBox(height: 2),
            Text(
              'Type: ${card['types'].join(', ')}',
              style: TextStyle(fontSize: 24), // Increase font size for Type
            ),
            SizedBox(height: 2),
            Text(
              'Rarity: ${card['rarity']}',
              style: TextStyle(fontSize: 24), // Increase font size for Rarity
            ),
            SizedBox(height: 16),
            Text(
              card['flavorText'] ?? '',
              style: TextStyle(fontSize: 21, fontStyle: FontStyle.italic), // Increase font size for Flavor Text
            ),
          ],
        ),
      ),
    );
  }
}
