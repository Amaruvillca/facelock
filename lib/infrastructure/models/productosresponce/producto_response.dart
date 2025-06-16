import 'dart:convert';

class ProductoResponse {
  final String message;
  final List<ProductoProductoDb> data;

  ProductoResponse({required this.message, required this.data});

  factory ProductoResponse.fromRawJson(String str) =>
      ProductoResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductoResponse.fromJson(Map<String, dynamic> json) =>
      ProductoResponse(
        message: json["message"],
        data: List<ProductoProductoDb>.from(json["data"].map((x) => ProductoProductoDb.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ProductoProductoDb {
  final int idProducto;
  final String nombre;
  final String descripcion;
  final String imagen;
  final DateTime fechaCreacion;
  final String genero;
  final double precio;
  final String para;
  final int idSucursal;
  final int idCategoria;
  final dynamic bannerProducto;
  final double promedioCalificacion;

  ProductoProductoDb({
    required this.idProducto,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.fechaCreacion,
    required this.genero,
    required this.precio,
    required this.para,
    required this.idSucursal,
    required this.idCategoria,
    required this.bannerProducto,
    required this.promedioCalificacion,
  });

  factory ProductoProductoDb.fromRawJson(String str) => ProductoProductoDb.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductoProductoDb.fromJson(Map<String, dynamic> json) => ProductoProductoDb(
    idProducto: json["id_producto"],
    nombre: json["nombre"],
    descripcion: json["descripcion"],
    imagen: json["imagen"],
    fechaCreacion: DateTime.parse(json["fecha_creacion"]),
    genero: json["genero"],
    precio: json["precio"]?.toDouble(),
    para:json["para"],
    idSucursal: json["id_sucursal"],
    idCategoria: json["id_categoria"],
    bannerProducto: json["banner_producto"],
    promedioCalificacion: json["promedio_calificacion"],
  );

  Map<String, dynamic> toJson() => {
    "id_producto": idProducto,
    "nombre": nombre,
    "descripcion": descripcion,
    "imagen": imagen,
    "fecha_creacion": fechaCreacion.toIso8601String(),
    "genero": genero,
    "precio": precio,
    "para": para,
    "id_sucursal": idSucursal,
    "id_categoria": idCategoria,
    "banner_producto": bannerProducto,
    "promedio_calificacion": promedioCalificacion,
  };
}




