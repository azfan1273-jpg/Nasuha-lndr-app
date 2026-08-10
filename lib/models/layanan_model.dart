class Layanan {
  final int id;
  final String namaLayanan;
  final double harga;
  final String satuan;
  final double estimasiHari;

  Layanan({
    required this.id,
    required this.namaLayanan,
    required this.harga,
    required this.satuan,
    required this.estimasiHari,
  });

  factory Layanan.fromJson(Map<String, dynamic> json) {
    return Layanan(
      id: json['id'] ?? 0,
      namaLayanan: json['nama_layanan'] ?? '',
      harga: (json['harga'] ?? 0).toDouble(),
      satuan: json['satuan'] ?? 'Kg',
      estimasiHari: (json['estimasi_hari'] ?? 1).toDouble(),
    );
  }
}
