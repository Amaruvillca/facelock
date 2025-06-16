import 'package:facelock/domain/entities/producto.dart';
import 'package:facelock/infrastructure/models/productosresponce/producto_response.dart';

class ProductoMapper {

  static Producto resultProducto(ProductoProductoDb productodb) =>Producto(
    idProducto: productodb.idProducto, 
    nombre: productodb.nombre, 
    descripcion: productodb.descripcion, 
    imagen: (productodb.imagen == '' || productodb.imagen.startsWith('img/productos/'))
    ? "noimagen.jpg"
    : productodb.imagen,
    fechaCreacion: productodb.fechaCreacion, 
    genero: productodb.genero, 
    precio: productodb.precio, 
    para: productodb.para, 
    idSucursal: productodb.idSucursal, 
    idCategoria: productodb.idCategoria, 
    bannerProducto: (productodb.bannerProducto == '' || productodb.bannerProducto == null)
    ? "Sin Banner"
    : productodb.bannerProducto,
    promedioCalificacion: productodb.promedioCalificacion
    
    );
}