class Pelanggan {
  final int id;
  final String nama;
  final String noHp;
  final String? tokoId;

  Pelanggan({
    required this.id,
    required this.nama,
    required this.noHp,
    this.tokoId,
  });

  factory Pelanggan.fromJson(Map<String, dynamic> json) {
    return Pelanggan(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? json['nama_pelanggan'] ?? 'Pelanggan',
      noHp: json['no_hp'] ?? '-',
      tokoId: json['toko_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'no_hp': noHp,
      if (tokoId != null) 'toko_id': tokoId,
    };
  }
}
