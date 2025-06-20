import 'package:facelock/domain/entities/categoria.dart';
import 'package:facelock/domain/entities/color_producto.dart';
import 'package:facelock/domain/entities/sucursal.dart';

class ProductoVariantes {
  final int idProducto;
  final String nombre;
  final String descripcion;
  final String imagen;
  final DateTime fechaCreacion;
  final String genero;
  final double precio;
  final String para;
  final Sucursal sucursal;
  final Categoria categoria;
  final List<ColorProducto> colores;

  ProductoVariantes({
    required this.idProducto,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.fechaCreacion,
    required this.genero,
    required this.precio,
    required this.para,
    required this.sucursal,
    required this.categoria,
    required this.colores,
  });

  factory ProductoVariantes.fromJson(Map<String, dynamic> json) {
    return ProductoVariantes(
      idProducto: json['id_producto'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagen: json['imagen'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      genero: json['genero'],
      precio: json['precio'].toDouble(),
      para: json['para'],
      sucursal: Sucursal.fromJson(json['sucursal']),
      categoria: Categoria.fromJson(json['categoria']),
      colores: (json['colores'] as List)
          .map((e) => ColorProducto.fromJson(e))
          .toList(),
    );
  }
}
