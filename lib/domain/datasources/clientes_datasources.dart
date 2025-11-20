import 'package:facelock/domain/entities/clientes.dart';

abstract class ClientesDatasources {

  Future <bool> getEstadoAutentificacion({String uid = ''});
  //Future <Map<String, dynamic>> getUserData({String uid = ''});
  Future <bool> registrarCliente({required Clientes cliente});
  Future <bool> iniciarSesion({required String email});
  
}
