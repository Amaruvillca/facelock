import 'package:facelock/domain/entities/clientes.dart';

abstract class ClientesRepositorie {
  Future <bool> getEstadoAutentificacion({String uid = ''});
  Future <bool> registrarCliente({required Clientes cliente});
  Future <bool> iniciarSesion({required String email});
}