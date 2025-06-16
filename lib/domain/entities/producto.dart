class Producto {
  final int idProducto;
  final String nombre;
  final String descripcion;
  final String imagen;
  final DateTime fechaCreacion;
  final String genero;
  final double precio;
  final String para;
  final int idSucursal;
  final int idCategoria;
  final String bannerProducto;
  final double promedioCalificacion;

  Producto(
    {required this.idProducto, 
    required this.nombre, 
    required this.descripcion,
    required this.imagen,
    required this.fechaCreacion,
    required this.genero, 
    required this.precio, 
    required this.para, 
    required this.idSucursal, 
    required this.idCategoria, 
    required this.bannerProducto , 
    required this.promedioCalificacion
    });

}