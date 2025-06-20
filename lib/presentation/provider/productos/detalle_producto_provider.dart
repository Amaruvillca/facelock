import 'package:facelock/domain/entities/productos_variantes.dart';
import 'package:facelock/presentation/provider/productos/producto_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef GetProductoCallback = Future<ProductoVariantes> Function(int idProducto);

class ProductoDetalleNotifier extends StateNotifier<AsyncValue<ProductoVariantes>> {
  final GetProductoCallback getProducto;
  final Ref ref;

  ProductoDetalleNotifier({
    required this.getProducto,
    required this.ref,
  }) : super(const AsyncValue.loading());

  Future<void> loadProducto(int idProducto) async {
    try {
      state = const AsyncValue.loading();
      
      // Primero buscamos en memoria
      final productosEnMemoria = ref.read(productoMemoriaProvider);
      final productoEnMemoria = productosEnMemoria.where((p) => p.idProducto == idProducto).toList();

      if (productoEnMemoria.isNotEmpty) {
        // Si está en memoria, lo usamos directamente
        state = AsyncValue.data(productoEnMemoria.first);
      } else {
        // Si no está en memoria, hacemos la petición
        final producto = await getProducto(idProducto);
        
        // Lo agregamos a memoria para futuras consultas
        ref.read(productoMemoriaProvider.notifier).update((state) => [...state, producto]);
        
        state = AsyncValue.data(producto);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final productoDetalleProvider = StateNotifierProvider<ProductoDetalleNotifier, AsyncValue<ProductoVariantes>>((ref) {
  final repo = ref.watch(productoREpositorioProvider);
  return ProductoDetalleNotifier(
    getProducto: repo.getDetalleProducto,
    ref: ref,
  );
});

final productoMemoriaProvider = StateProvider<List<ProductoVariantes>>((ref) => []);