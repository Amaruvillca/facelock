import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 30,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(PhosphorIconsRegular.heart, color: Colors.red),
          title: Text('Producto favorito ${index + 1}'),
          subtitle: Text('Descripción del producto'),
        );
      },
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
     