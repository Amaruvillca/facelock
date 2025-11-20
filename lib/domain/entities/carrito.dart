class Carrito {
  final int idCarrito;
  final DateTime fechaCreacion;
  final String estado;
  final int idCliente;

  Carrito({
    required this.idCarrito,
    required this.fechaCreacion,
    required this.estado,
    required this.idCliente
  });
  factory Carrito.fromJson(Map<String, dynamic> json) {
    return Carrito(
      idCarrito: json['id_carrito'],
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      estado: json['estado'],
      idCliente: json['id_cliente'],
    );
  }
}