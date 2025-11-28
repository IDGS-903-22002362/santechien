class ActualizarMascotaRequest {
  final String? nombre;
  final String? especie;
  final String? raza;
  final String? fechaNacimiento; // ISO format: 2025-11-28T09:40:51.852Z
  final int? sexo; // 1 = Macho, 2 = Hembra
  final String? personalidad;
  final String? estadoSalud;
  final String? notas;

  ActualizarMascotaRequest({
    this.nombre,
    this.especie,
    this.raza,
    this.fechaNacimiento,
    this.sexo,
    this.personalidad,
    this.estadoSalud,
    this.notas,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (nombre != null) data['nombre'] = nombre;
    if (especie != null) data['especie'] = especie;
    if (raza != null) data['raza'] = raza;
    if (fechaNacimiento != null) data['fechaNacimiento'] = fechaNacimiento;
    if (sexo != null) data['sexo'] = sexo;
    if (personalidad != null) data['personalidad'] = personalidad;
    if (estadoSalud != null) data['estadoSalud'] = estadoSalud;
    if (notas != null) data['notas'] = notas;

    return data;
  }

  @override
  String toString() {
    return 'ActualizarMascotaRequest{nombre: $nombre, especie: $especie, raza: $raza, sexo: $sexo, personalidad: $personalidad}';
  }
}
