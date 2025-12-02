class Sucursal {
  final int idSucursal;
  final String nombre;
  final String direccion;
  final String? imagen1;
  final String? imagen2;
  final String? imagen3;
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
    this.imagen1,
    this.imagen2,
    this.imagen3,
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
      latitud: json['latitud'],
      longitud: json['longitud'],
      estado: json['estado'],
    );
  }
}

class SucursalResponse {
  final String message;
  final List<Sucursal> data;

  SucursalResponse({
    required this.message,
    required this.data,
  });

  factory SucursalResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<Sucursal> sucursales = dataList
        .map((item) => Sucursal.fromJson(item))
        .toList();

    return SucursalResponse(
      message: json['message'],
      data: sucursales,
    );
  }
}