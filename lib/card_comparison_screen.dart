import 'dart:math';
import 'package:flutter/material.dart';

class CardComparisonScreen extends StatefulWidget {
  final List<dynamic> pokemonCards;

  CardComparisonScreen({required this.pokemonCards});

  @override
  _CardComparisonScreenState createState() => _CardComparisonScreenState();
}

class _CardComparisonScreenState extends State<CardComparisonScreen> {
  dynamic card1;
  dynamic card2;
  String result = '';

  @override
  void initState() {
    super.initState();
    _selectRandomCards();
  }

  void _selectRandomCards() {
    final random = Random();
    if (widget.pokemonCards.length < 2) {
      result = 'Not enough cards to compare.';
      return;
    }
    card1 = widget.pokemonCards[random.nextInt(widget.pokemonCards.length)];
    card2 = widget.pokemonCards[random.nextInt(widget.pokemonCards.length)];

    final hp1 = int.tryParse(card1['hp'] ?? '0') ?? 0;
    final hp2 = int.tryParse(card2['hp'] ?? '0') ?? 0;

    if (hp1 > hp2) {
      result = '${card1['name']} wins!';
    } else if (hp2 > hp1) {
      result = '${card2['name']} wins!';
    } else {
      result = 'It\'s a tie!';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Comparison'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            card1 == null || card2 == null
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      _buildCardDisplay(card1),
                      SizedBox(height: 20),
                      _buildCardDisplay(card2),
                      SizedBox(height: 20),
                      Text(
                        result,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
            ElevatedButton(
              onPressed: _selectRandomCards,
              child: Text('Compare Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDisplay(dynamic card) {
    final hp = int.tryParse(card['hp'] ?? '0') ?? 0;
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.network(card['images']?['small'] ?? '', width: 100),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card['name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('HP: $hp', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
