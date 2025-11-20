class Sucursal {
  final int idSucursal;
  final String nombre;
  final String direccion;
  final String imagen1;
  final String imagen2;
  final String imagen3;
  final int telefono;
  final DateTime fechaApertura;
  final String ciudad;
  final double latitud;
  final double longitud;
  final bool estado;

  Sucursal({
    required this.idSucursal,
    required this.nombre,
    required this.direccion,
    required this.imagen1,
    required this.imagen2,
    required this.imagen3,
    required this.telefono,
    required this.fechaApertura,
    required this.ciudad,
    required this.latitud,
    required this.longitud,
    required this.estado,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      idSucursal: json['id_sucursal'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      imagen1: json['imagen1'],
      imagen2: json['imagen2'],
      imagen3: json['imagen3'],
      telefono: json['telefono'],
      fechaApertura: DateTime.parse(json['fecha_apertura']),
      ciudad: json['ciudad'],
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
      estado: json['estado'],
    );
  }
}
