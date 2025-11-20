
import 'package:facelock/domain/entities/producto_carrito.dart';

abstract class CarritoDatasource {

  Future <List<ProductoCarrito>> getProductosCarritoActivos({required String uid});
}