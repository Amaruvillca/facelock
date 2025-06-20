import 'dart:async';
import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/presentation/provider/providers.dart';
import 'package:facelock/presentation/widgets/home/producto_vertial_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SeachProductosCallback = Future<List<Producto>> Function(String busqueda);

class SearchProducto extends SearchDelegate<Producto?> {
  final SeachProductosCallback searchproducto;
  final WidgetRef ref;
  final List<String> historial;

  List<Producto> productoList;
  final StreamController<List<Producto>> _debounceStream = StreamController.broadcast();
  Timer? _debounceTimer;

  SearchProducto({
    super.searchFieldLabel = "Buscar productos...",
    super.searchFieldStyle,
    super.keyboardType,
    super.textInputAction,
    super.autocorrect,
    super.enableSuggestions,
    required this.searchproducto,
    required this.productoList,
    required this.ref,
    required this.historial,
  });

  void _onQueryChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        _debounceStream.add([]);
        return;
      }

      final productos = await searchproducto(query);
      _debounceStream.add(productos);

      ref.read(seachQueryProductoPrivider.notifier).update((state) => query);
      ref.read(guardarListaDeBusqueda.notifier).update((state) => productos);

      productoList = productos;
    });
  }

  Widget buildResultSearch() {
    return StreamBuilder<List<Producto>>(
      stream: _debounceStream.stream,
      initialData: productoList,
      builder: (context, snapshot) {
        final productos = snapshot.data ?? [];

        if (productos.isEmpty && query.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No encontramos resultados',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Intenta con otras palabras clave',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: productos.isEmpty && query.isEmpty
              ? Container()
              : GridView.builder(
                  key: ValueKey('grid-${productos.length}'),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    return CardVertical(producto: productos[index]);
                  },
                ),
        );
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: false,
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Buscar productos...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            ref.read(seachQueryProductoPrivider.notifier).state = '';
            ref.read(guardarListaDeBusqueda.notifier).state = [];
            _debounceStream.add([]);
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historial = ref.read(historialDeBusqueda);
      final yaExiste = historial.any((item) => item.toLowerCase() == query.toLowerCase());

      if (!yaExiste && query.trim().isNotEmpty) {
        ref.read(historialDeBusqueda.notifier).update((state) => [query, ...state]);
        historial.add(query);
      }
    });

    return buildResultSearch();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _onQueryChanged(query);
    return query.isEmpty ? _buildRecentSearches(context) : buildResultSearch();
  }

  Widget _buildRecentSearchesItem(String search, BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(search),
      onTap: () {
        query = search;
        _onQueryChanged(query);
        showResults(context);
      },
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _loadRecentSearches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recentSearches = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Búsquedas recientes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (recentSearches.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Busca productos por nombre',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: recentSearches.length,
                  itemBuilder: (context, index) {
                    return _buildRecentSearchesItem(recentSearches[index], context);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Future<List<String>> _loadRecentSearches() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return historial;
  }

  @override
  void close(BuildContext context, Producto? result) {
    _debounceTimer?.cancel();
    _debounceStream.close();
    super.close(context, result);
  }
}