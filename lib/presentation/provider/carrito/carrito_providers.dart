import 'package:facelock/domain/entities/producto_carrito.dart';
import 'package:facelock/presentation/provider/carrito/carrito_repositorie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final carritoPendienteProvider =
    StateNotifierProvider<ProductoNotifierProvider, List<ProductoCarrito>>((ref) {
  final fetchProductos = ref.watch(carritoREpositorioProvider).getProductosCarritoActivos;
  return ProductoNotifierProvider(fetchProductos: fetchProductos);
});

typedef ProductoCallback = Future<List<ProductoCarrito>> Function({required String uid});

class ProductoNotifierProvider extends StateNotifier<List<ProductoCarrito>> {
  final ProductoCallback fetchProductos;

  ProductoNotifierProvider({required this.fetchProductos}) : super([]);

  bool isLoading = false;

  Future<void> cargarCarritoPendiente(String uid) async {
    if (isLoading) return;
    isLoading = true;

    try {
      final productos = await fetchProductos(uid: uid);
      state = productos;
    } catch (e) {
      // Log opcional
      print('Error al cargar productos del carrito: $e');
    }

    isLoading = false;
  }
}
