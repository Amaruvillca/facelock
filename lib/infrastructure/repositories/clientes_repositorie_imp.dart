import 'package:facelock/domain/datasources/clientes_datasources.dart';
import 'package:facelock/domain/entities/clientes.dart';
import 'package:facelock/domain/repositories/clientes_repositorie.dart';

class ClientesRepositorieImp extends ClientesRepositorie {
  final ClientesDatasources datasources;

  ClientesRepositorieImp(this.datasources);
  @override
  Future<bool> getEstadoAutentificacion({String uid = ''}) {
    
    return datasources.getEstadoAutentificacion(uid: uid);
  }

  @override
  Future<bool> iniciarSesion({required String email}) {
    return datasources.iniciarSesion(email: email);
  }

  @override
  Future<bool> registrarCliente({required Clientes cliente}) {
    return datasources.registrarCliente(cliente: cliente);
  }
}