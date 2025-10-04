class Usuario {
  final BigInt id;
  final String? nombre;
  final String? correo;
  final String? telefono;
  final String? username;
  final int tipoUsuario; // 1 = Tutor (Admin), 2 = Estudiante
  final String? fotoUrl;
  final String? codigoInvitacion;
  final BigInt? tutorId;
  final String? estado;

  Usuario(
      {required this.id,
      this.nombre,
      this.correo,
      this.telefono,
      this.username,
      required this.tipoUsuario,
      this.fotoUrl,
      this.codigoInvitacion,
      this.tutorId,
      this.estado});

  // Factory para crear un Usuario desde el JSON de la API
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
        id: BigInt.parse(json['id_usuario'].toString()),
        nombre: json['nombre'],
        correo: json['correo'],
        telefono: json['telefono'],
        username: json['username'],
        tipoUsuario: json['tipo_usuario'],
        fotoUrl: json['foto_url'],
        codigoInvitacion: json["codigo_invitacion"],
        tutorId: json['tutor_id'] != null
            ? BigInt.tryParse(json['tutor_id'].toString())
            : null,
        estado: json['estado_relacion']);
  }

  // Getter para saber fácilmente si es admin
  bool get isAdmin => tipoUsuario == 1;

  bool get isAccepted => estado == 'ACEPTADO';

  bool get isPending => estado == 'PENDIENTE';

  bool get isRejected => estado == 'RECHAZADO';
}
