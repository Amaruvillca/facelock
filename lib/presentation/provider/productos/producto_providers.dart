import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/presentation/provider/productos/producto_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recientesProductosProvider = StateNotifierProvider<ProductoNotifierProvider,List<Producto>>((ref){
  final fetchMoreProductos = ref.watch(productoREpositorioProvider).getRecientes;
return ProductoNotifierProvider(
  fetchProductos:fetchMoreProductos,
);
});

final getProductosProvider = StateNotifierProvider<ProductoNotifierProvider,List<Producto>>((ref){
  final fetchMoreProducto = ref.watch(productoREpositorioProvider).getProductos;
return ProductoNotifierProvider(
  fetchProductos:fetchMoreProducto,
);
});
final getMejoresCalificadasProvider = StateNotifierProvider<ProductoNotifierProvider,List<Producto>>((ref){
  final fetchMoreProducto = ref.watch(productoREpositorioProvider).getMejoresCalificadas;
return ProductoNotifierProvider(
  fetchProductos:fetchMoreProducto,
);
});

final getSimilaresProvider = StateNotifierProvider<ProductoNotifierProvider,List<Producto>>((ref){
  final fetchMoreProducto = ref.watch(productoREpositorioProvider).getSimilares;
return ProductoNotifierProvider(
  fetchProductos:fetchMoreProducto,
);
});

typedef ProductoCallback = Future<List<Producto>> Function({int page});
class ProductoNotifierProvider extends StateNotifier<List<Producto>>{
int currentPage = 0;
bool isLoading = false;
ProductoCallback fetchProductos;
  ProductoNotifierProvider(
    {required this.fetchProductos}
  ):super([]);


Future<void> loadNextPage() async {
  if(isLoading) return;
  print('Loading next page');

  isLoading = true;
  currentPage++;
  final List<Producto> movies = await fetchProductos(page: currentPage);
  state = [...state, ...movies];
  await Future.delayed(const Duration(milliseconds: 300));
  isLoading = false;
}
Future<void> loadSimilar(int idProducto) async {
  if(isLoading) return;
  print('Loading similar products');

  isLoading = true;
  
  final List<Producto> movies = await fetchProductos(page: idProducto);
  state = [...movies];
  await Future.delayed(const Duration(milliseconds: 300));
  isLoading = false;
}

}

