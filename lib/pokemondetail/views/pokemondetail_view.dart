import 'package:flutter/material.dart';
import '../../pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemondetailView extends StatefulWidget {
  final PokemonListItem pokemonListItem;

  const PokemondetailView({super.key, required this.pokemonListItem});

  @override
  State<PokemondetailView> createState() => _PokemondetailViewState();
}

class _PokemondetailViewState extends State<PokemondetailView> {
  Map<String, dynamic>? _pokemonData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPokemonDetails();
  }

  Future<void> loadPokemonDetails() async {
    final response = await http.get(Uri.parse(widget.pokemonListItem.url));
    if (response.statusCode == 200) {
      setState(() {
        _pokemonData = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception('Failed to load details');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemonListItem.name.toUpperCase()),
      ),
      body: _pokemonData == null
          ? const Center(child: Text('No data found'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Image.network(
                      _pokemonData!['sprites']['front_default'],
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "ชื่อ: ${widget.pokemonListItem.name.toUpperCase()}",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("น้ำหนัก: ${_pokemonData!['weight']}"),
                  Text("ความสูง: ${_pokemonData!['height']}"),
                  const SizedBox(height: 20),
                  const Text("ประเภท:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    children: (_pokemonData!['types'] as List)
                        .map((t) => Chip(label: Text(t['type']['name'])))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text("ความสามารถ:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    children: (_pokemonData!['abilities'] as List)
                        .map((a) => Chip(label: Text(a['ability']['name'])))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text("ค่าสถานะเริ่มต้น:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Column(
                    children: (_pokemonData!['stats'] as List)
                        .map((s) => Text(
                            "${s['stat']['name']}: ${s['base_stat']}",
                            style: const TextStyle(fontSize: 16)))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
