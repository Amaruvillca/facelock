import 'package:facelock/domain/entities/talla_producto.dart';

class ColorProducto {
  final int idColorProducto;
  final String colores;
  final String codProducto;
  final String descripcion;
  final String imagen;
  final int idProducto;
  final List<TallaProducto> tallas;

  ColorProducto({
    required this.idColorProducto,
    required this.colores,
    required this.codProducto,
    required this.descripcion,
    required this.imagen,
    required this.idProducto,
    required this.tallas,
  });

  factory ColorProducto.fromJson(Map<String, dynamic> json) {
    return ColorProducto(
      idColorProducto: json['id_color_producto'],
      colores: json['colores'],
      codProducto: json['cod_producto'],
      descripcion: json['descripcion'],
      imagen: json['imagen'],
      idProducto: json['id_producto'],
      tallas: (json['tallas'] as List)
          .map((e) => TallaProducto.fromJson(e))
          .toList(),
    );
  }
}
