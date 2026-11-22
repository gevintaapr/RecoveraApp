import 'package:hive/hive.dart';

// File ini dibuat otomatis oleh build_runner (Modul VI):
//   dart run build_runner build --delete-conflicting-outputs
part 'listing_model.g.dart';

// Model listing lelang dari GET /listings dan GET /listings/{id}.
// Harga lelang Belanda DIHITUNG SERVER (current_price, next_drop_at);
// aplikasi hanya menampilkan, tidak menghitung ulang.
//
// @HiveType: listing juga disimpan di Hive box 'listings_cache'
// sebagai katalog terakhir, untuk ditampilkan saat offline (Modul VI).
@HiveType(typeId: 1)
class ListingModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String namaProduk;
  @HiveField(2)
  final String? merek;
  @HiveField(3)
  final String kategori;
  @HiveField(4)
  final String satuan; // mis. kg, pcs, karton
  @HiveField(5)
  final String? urlGambar;
  @HiveField(6)
  final int stok;
  @HiveField(7)
  final double hargaNormal;
  @HiveField(8)
  final double hargaMinimum;
  @HiveField(9)
  final double hargaSekarang;
  @HiveField(10)
  final double? persenDiskon;
  @HiveField(11)
  final DateTime? waktuTurunBerikutnya;
  @HiveField(12)
  final DateTime lelangBerakhir;
  @HiveField(13)
  final DateTime tanggalKedaluwarsa;
  @HiveField(14)
  final int? sisaHari;
  @HiveField(15)
  final String? namaPenjual;
  @HiveField(16)
  final String? kotaGudang;
  @HiveField(17)
  final double? jarakKm; // terisi bila katalog diminta dengan lat/lng
  @HiveField(19)
  final double? latGudang; // koordinat gudang penjual, untuk hitung jarak di detail
  @HiveField(20)
  final double? lngGudang;
  @HiveField(18)
  final String status;
  @HiveField(21)
  final String? nomorBatch;
  @HiveField(22)
  final String? jenisPenyimpanan;

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
    this.latGudang,
    this.lngGudang,
    required this.status,
    this.nomorBatch,
    this.jenisPenyimpanan,
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
      latGudang: (json['warehouse_lat'] as num?)?.toDouble(),
      lngGudang: (json['warehouse_lng'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'active',
      nomorBatch: json['batch_number'] as String?,
      jenisPenyimpanan: produk['storage_type'] as String?,
    );
  }

  // Persen potongan dari harga normal. Pakai nilai server bila ada.
  int get diskonPersen {
    if (persenDiskon != null) return persenDiskon!.round();
    if (hargaNormal <= 0) return 0;
    return ((1 - hargaSekarang / hargaNormal) * 100).round();
  }

  // Teks status listing untuk penjual (halaman Stok).
  String get labelStatus {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'review':
        return 'Siap terbit';
      case 'active':
        return 'Aktif';
      case 'sold':
        return 'Habis';
      case 'expired':
        return 'Kedaluwarsa';
      default:
        return status;
    }
  }

  bool get masihDraft => status == 'draft' || status == 'review';

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
