class Resena {
  final int? id;
  final int recetaId;
  final String nombre;
  final String comentario;
  const Resena ({
    this.id,
    required this.recetaId,
    required this.nombre,
    required this.comentario,
  });
  Map<String, Object> toMap() {
    return {
      'receta_id': recetaId,
      'nombre' : nombre,
      'comentario' : comentario,

    };
  }
  factory Resena.fromMap(Map<String, Object?> map) {
    return Resena (
      id: map['id'] as int?,
      recetaId: map['receta_id'] as int,
      nombre: map['nombre'] as String,
      comentario: map['comentario'] as String,
    );
  }
}