class ProductoCarrito {
  final int? idProductoCarrito;
  final int? idCarrito;
  final DateTime fechaAnadido;
  final int cantidad;
  final String talla;
  final double precioUnitario;
  final double precioTotal;
  final int idColorProducto;
  final String? descripcion;
  final String? imagen;

  ProductoCarrito({
    this.idProductoCarrito = 0,
    this.idCarrito = 0,
    required this.fechaAnadido,
    required this.cantidad,
    required this.talla,
    required this.precioUnitario,
    required this.precioTotal,
    required this.idColorProducto,
    this.descripcion = '',
    this.imagen = '',
  });

  Map<String, dynamic> toJson() => {
        'fecha_anadido': fechaAnadido.toIso8601String(),
        'cantidad': cantidad,
        'talla': talla,
        'precio_unitario': precioUnitario,
        'precio_total': precioTotal,
        'id_color_producto': idColorProducto,
      };

  factory ProductoCarrito.fromJson(Map<String, dynamic> json) {
  return ProductoCarrito(
    idProductoCarrito: json['id_producto_carrito'] as int?,
    idCarrito: json['id_carrito'] as int?,
    fechaAnadido: DateTime.parse(json['fecha_anadido']),
    cantidad: json['cantidad'],
    talla: json['talla'],
    precioUnitario: (json['precio_unitario'] as num).toDouble(),
    precioTotal: (json['precio_total'] as num).toDouble(),
    idColorProducto: json['id_color_producto'],
    descripcion: json['descripcion'] as String?,
    imagen: json['imagen'] as String?,
  );
}

}
