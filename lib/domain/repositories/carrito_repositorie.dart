import 'package:facelock/domain/entities/producto_carrito.dart';

abstract class CarritoRepositorie {
  Future <List<ProductoCarrito>> getProductosCarritoActivos({required String uid});
}