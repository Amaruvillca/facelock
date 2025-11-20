import 'package:facelock/domain/datasources/carrito_datasource.dart';
import 'package:facelock/domain/entities/producto_carrito.dart';
import 'package:facelock/domain/repositories/carrito_repositorie.dart';

class CarritoRepositoriesImp extends CarritoRepositorie{
  final CarritoDatasource datasources;

  CarritoRepositoriesImp(this.datasources);
  @override
  Future<List<ProductoCarrito>> getProductosCarritoActivos({required String uid}) {
    // TODO: implement getProductosCarritoActivos
    return datasources.getProductosCarritoActivos(uid: uid);
  }
}