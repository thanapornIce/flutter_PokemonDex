import 'package:flutter/material.dart';
import '../../pokemondetail/views/pokemondetail_view.dart';
import '../models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  List<PokemonListItem> _pokemonList = [];
  String? nextUrl = "https://pokeapi.co/api/v2/pokemon"; // API หน้าแรก
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (nextUrl == null || isLoading)
      return; // ถ้าไม่มีหน้าถัดไป หรือกำลังโหลดอยู่ ไม่ทำอะไร
    setState(() => isLoading = true);

    final response = await http.get(Uri.parse(nextUrl!));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _pokemonList.addAll((data['results'] as List)
            .map((x) => PokemonListItem.fromJson(x))
            .toList());
        nextUrl = data['next']; // อัปเดต URL หน้าถัดไป
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      throw Exception('Failed to load Pokemon');
    }
  }

  Future<String> fetchPokemonImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['sprites']['front_default'] ?? "";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _pokemonList.length,
            itemBuilder: (context, index) {
              final PokemonListItem pokemon = _pokemonList[index];
              return FutureBuilder<String>(
                future: fetchPokemonImage(pokemon.url), // โหลดรูป
                builder: (context, snapshot) {
                  return ListTile(
                    leading: snapshot.hasData
                        ? Image.network(snapshot.data!, width: 50, height: 50)
                        : const CircularProgressIndicator(),
                    title: Text(pokemon.name.toUpperCase()),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemondetailView(
                          pokemonListItem: pokemon,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (isLoading) const CircularProgressIndicator(),
        ElevatedButton(
          onPressed: loadData,
          child: const Text("โหลดเพิ่ม"),
        ),
      ],
    );
  }
}
