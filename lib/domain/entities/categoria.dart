class Categoria {
  final int idCategoria;
  final String nombre;
  final String descripcion;
  final String imagen;
  final int estado;

  Categoria({
    required this.idCategoria,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.estado,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria: json['id_categoria'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagen: json['imagen'],
      estado: json['estado'],
    );
  }
}
