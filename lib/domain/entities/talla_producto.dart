class TallaProducto {
  final int idTallaProducto;
  final String talla;
  final int stock;
  final String descripcion;
  final int idColorProducto;

  TallaProducto({
    required this.idTallaProducto,
    required this.talla,
    required this.stock,
    required this.descripcion,
    required this.idColorProducto,
  });

  factory TallaProducto.fromJson(Map<String, dynamic> json) {
    return TallaProducto(
      idTallaProducto: json['id_talla_producto'],
      talla: json['talla'],
      stock: json['stock'],
      descripcion: json['descripcion'],
      idColorProducto: json['id_color_producto'],
    );
  }
}
