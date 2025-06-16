import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchResultsScreen extends StatefulWidget {
  final String imagePath;

  const SearchResultsScreen({super.key, required this.imagePath});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<List<String>> _searchResults;
  bool _imageExists = true;

  @override
  void initState() {
    super.initState();
    _checkImage();
    _searchResults = _fetchSearchResults();
  }

  Future<void> _checkImage() async {
    final file = File(widget.imagePath);
    final exists = await file.exists();
    if (!exists && mounted) {
      setState(() => _imageExists = false);
    }
  }

  Future<List<String>> _fetchSearchResults() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      return ['Producto 1', 'Producto 2', 'Producto 3', 'Producto 4'];
    } catch (e) {
      throw Exception('Error al buscar productos: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados de Búsqueda'),
      ),
      body: !_imageExists
          ? const Center(child: Text('La imagen no está disponible'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imagePath),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        height: 200,
                        child: const Center(child: Icon(Icons.error)),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Productos similares encontrados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<String>>(
                    future: _searchResults,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      }
                      
                      final results = snapshot.data!;
                      return ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.search),
                            title: Text(results[index]),
                            onTap: () {
                              context.push('/product-detail', extra: results[index]);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}