import 'package:facelock/domain/datasources/clientes_datasources.dart';
import 'package:facelock/domain/repositories/clientes_repositorie.dart';

class ClientesRepositorieImp extends ClientesRepositorie {
  final ClientesDatasources datasources;

  ClientesRepositorieImp(this.datasources);
  @override
  Future<bool> getEstadoAutentificacion({String uid = ''}) {
    // TODO: implement getEstadoAutentificacion
    return datasources.getEstadoAutentificacion(uid: uid);
  }
}