import 'package:flutter/material.dart';

class SearchProducto extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: query.isNotEmpty
            ? IconButton(
                key: const ValueKey('clear-button'),
                icon: const Icon(Icons.clear),
                onPressed: () {
                  query = '';
                  showSuggestions(context);
                },
              )
            : const SizedBox.shrink(),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isEmpty ? _buildRecentSearches() : _buildSearchResults();
  }

  Widget _buildRecentSearches() {
    return FutureBuilder<List<String>>(
      future: _loadRecentSearches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(snapshot.data![index]),
              onTap: () {
                query = snapshot.data![index];
                showResults(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _simulateSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return ListTile(
              title: Text(item['title']),
              subtitle: Text(item['subtitle']),
              onTap: () {
                close(context, item['id']);
              },
            );
          },
        );
      },
    );
  }

  Future<List<String>> _loadRecentSearches() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simula carga
    return ['Producto 1', 'Producto 2', 'Producto 3'];
  }

  Future<List<Map<String, dynamic>>> _simulateSearch(String query) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simula búsqueda
    return List.generate(5, (index) => {
      'id': 'result_$index',
      'title': '$query Resultado ${index + 1}',
      'subtitle': 'Descripción del resultado ${index + 1}'
    });
  }
}