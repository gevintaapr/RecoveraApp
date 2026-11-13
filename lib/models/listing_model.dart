// Model listing lelang dari GET /listings dan GET /listings/{id}.
// Harga lelang Belanda DIHITUNG SERVER (current_price, next_drop_at);
// aplikasi hanya menampilkan, tidak menghitung ulang.
class ListingModel {
  final int id;
  final String namaProduk;
  final String? merek;
  final String kategori;
  final String satuan; // mis. kg, pcs, karton
  final String? urlGambar;
  final int stok;
  final double hargaNormal;
  final double hargaMinimum;
  final double hargaSekarang;
  final double? persenDiskon;
  final DateTime? waktuTurunBerikutnya;
  final DateTime lelangBerakhir;
  final DateTime tanggalKedaluwarsa;
  final int? sisaHari;
  final String? namaPenjual;
  final String? kotaGudang;
  final double? jarakKm; // terisi bila katalog diminta dengan lat/lng
  final String status;

  ListingModel({
    required this.id,
    required this.namaProduk,
    this.merek,
    required this.kategori,
    required this.satuan,
    this.urlGambar,
    required this.stok,
    required this.hargaNormal,
    required this.hargaMinimum,
    required this.hargaSekarang,
    this.persenDiskon,
    this.waktuTurunBerikutnya,
    required this.lelangBerakhir,
    required this.tanggalKedaluwarsa,
    this.sisaHari,
    this.namaPenjual,
    this.kotaGudang,
    this.jarakKm,
    required this.status,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    // Data produk ada di objek "product" di dalam listing.
    final Map<String, dynamic> produk =
        json['product'] as Map<String, dynamic>? ?? {};
    final String? teksTurunBerikutnya = json['next_drop_at'] as String?;

    return ListingModel(
      id: json['id'] as int,
      namaProduk: produk['name'] as String? ?? 'Produk',
      merek: produk['brand'] as String?,
      kategori: produk['category'] as String? ?? '-',
      satuan: produk['default_unit'] as String? ?? 'unit',
      urlGambar: produk['image_url'] as String?,
      stok: json['qty'] as int? ?? 0,
      hargaNormal: (json['normal_price'] as num).toDouble(),
      hargaMinimum: (json['min_price'] as num).toDouble(),
      hargaSekarang: (json['current_price'] as num).toDouble(),
      persenDiskon: (json['discount_pct'] as num?)?.toDouble(),
      waktuTurunBerikutnya: teksTurunBerikutnya == null
          ? null
          : DateTime.parse(teksTurunBerikutnya).toLocal(),
      lelangBerakhir: DateTime.parse(json['auction_end_at'] as String).toLocal(),
      tanggalKedaluwarsa: DateTime.parse(json['expiry_date'] as String),
      sisaHari: json['days_to_expiry'] as int?,
      namaPenjual: json['seller_company'] as String?,
      kotaGudang: json['warehouse_city'] as String?,
      jarakKm: (json['distance_km'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'active',
    );
  }

  // Persen potongan dari harga normal. Pakai nilai server bila ada.
  int get diskonPersen {
    if (persenDiskon != null) return persenDiskon!.round();
    if (hargaNormal <= 0) return 0;
    return ((1 - hargaSekarang / hargaNormal) * 100).round();
  }

  // ===== Pembantu format tampilan (tanpa package tambahan) =====

  // 12500 -> "Rp12.500"
  static String formatRupiah(double angka) {
    final String digit = angka.round().toString();
    final StringBuffer hasil = StringBuffer();
    for (int i = 0; i < digit.length; i++) {
      final int sisa = digit.length - i;
      hasil.write(digit[i]);
      if (sisa > 1 && sisa % 3 == 1) hasil.write('.');
    }
    return 'Rp$hasil';
  }

  // 2.43 -> "2,4 km"
  static String formatJarak(double km) {
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  // 09:05
  static String formatJam(DateTime waktu) {
    final String jam = waktu.hour.toString().padLeft(2, '0');
    final String menit = waktu.minute.toString().padLeft(2, '0');
    return '$jam:$menit';
  }

  // 9 Nov 2026
  static String formatTanggal(DateTime tanggal) {
    const List<String> namaBulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${tanggal.day} ${namaBulan[tanggal.month - 1]} ${tanggal.year}';
  }
}
