class Clientes{
  final int? idCliente;
  final String? uid;
  final String? nombres;
  final String? apPaterno;
  final String? apMaterno;
  final String? ci;
  final String? fcmToken;
  final String? email;
  final String? password;
  final String? celular;
  final String? direccion;
  final String? fechaRegistro;
  final String? preferencias;
  final double? latitud;
  final double? longitud;
  final String? imagenCliente;

  Clientes({
    this.idCliente,
    this.uid,
    this.nombres,
    this.apPaterno,
    this.apMaterno,
    this.ci,
    this.fcmToken,
    this.email,
    this.password,
    this.celular,
    this.direccion,
    this.fechaRegistro,
    this.preferencias,
    this.latitud,
    this.longitud,
    this.imagenCliente,
  });

  factory Clientes.fromJson(Map<String, dynamic> json) {
    return Clientes(
      idCliente: json['id_cliente'],
      uid: json['uid'],
      nombres: json['nombres'],
      apPaterno: json['ap_paterno'],
      apMaterno: json['ap_materno'],
      ci: json['ci'],
      fcmToken: json['fcm_token'],
      email: json['email'],
      password: json['password'],
      celular: json['celular'],
      direccion: json['direccion'],
      fechaRegistro: json['fecha_registro'],
      preferencias: json['preferencias'],
      latitud: json['latitud'] != null ? double.tryParse(json['latitud'].toString()) : null,
      longitud: json['longitud'] != null ? double.tryParse(json['longitud'].toString()) : null,
      imagenCliente: json['imagen_cliente'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idCliente != null) '': idCliente,
      if (uid != null) 'uid': uid,
      if (nombres != null) 'nombres': nombres,
      if (apPaterno != null) 'ap_paterno': apPaterno,
      if (apMaterno != null) 'ap_materno': apMaterno,
      if (ci != null) 'ci': ci,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (celular != null) 'celular': celular,
      if (direccion != null) 'direccion': direccion,
      if (fechaRegistro != null) DateTime.now().toIso8601String(): fechaRegistro,
      if (preferencias != null) 'preferencias': preferencias,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (imagenCliente != null) 'imagen_cliente': imagenCliente,
    };
  }
}