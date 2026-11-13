// Model data pengguna dari endpoint GET /profile.
// Backend mengirim data umum + objek "seller" ATAU "buyer" sesuai peran.
class UserModel {
  final int id;
  final String email;
  final String peran; // 'seller' atau 'buyer'
  final String nama;
  final String? telepon;
  final String? namaPerusahaan; // khusus penjual
  final String? jenisUsaha; // khusus pembeli (resto, hotel, dll.)
  final String? alamat;
  final String? kota; // khusus penjual
  final double? latitude; // gudang (penjual) atau lokasi usaha (pembeli)
  final double? longitude;

  UserModel({
    required this.id,
    required this.email,
    required this.peran,
    required this.nama,
    this.telepon,
    this.namaPerusahaan,
    this.jenisUsaha,
    this.alamat,
    this.kota,
    this.latitude,
    this.longitude,
  });

  bool get isPenjual => peran == 'seller';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? dataPenjual =
        json['seller'] as Map<String, dynamic>?;
    final Map<String, dynamic>? dataPembeli =
        json['buyer'] as Map<String, dynamic>?;

    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      peran: json['role'] as String? ?? 'buyer',
      nama: json['name'] as String? ?? '',
      telepon: json['phone'] as String?,
      namaPerusahaan: dataPenjual?['company_name'] as String?,
      jenisUsaha: dataPembeli?['business_type'] as String?,
      alamat: (dataPenjual?['address'] ?? dataPembeli?['address']) as String?,
      kota: dataPenjual?['city'] as String?,
      latitude: _keDouble(dataPenjual?['warehouse_lat'] ?? dataPembeli?['base_lat']),
      longitude: _keDouble(dataPenjual?['warehouse_lng'] ?? dataPembeli?['base_lng']),
    );
  }

  // Angka dari JSON bisa berupa int atau double; samakan jadi double.
  static double? _keDouble(Object? nilai) {
    if (nilai is num) return nilai.toDouble();
    return null;
  }
}
