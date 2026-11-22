// Hasil OCR faktur dari POST /ai/invoice.
// Backend membaca foto faktur (Gemini), lalu mengembalikan daftar barang.
// Tiap barang bisa diketuk untuk mengisi form listing secara otomatis.
class InvoiceResultModel {
  final String? nomorFaktur;
  final String? namaPemasok;
  final List<InvoiceItemModel> daftarItem;
  final bool ditolak; // true bila foto bukan faktur / tidak terbaca
  final String? alasanDitolak;
  final bool pakaiDataContoh; // true bila OCR gagal dan server memakai data cadangan

  InvoiceResultModel({
    this.nomorFaktur,
    this.namaPemasok,
    required this.daftarItem,
    required this.ditolak,
    this.alasanDitolak,
    required this.pakaiDataContoh,
  });

  factory InvoiceResultModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemMentah = json['parsed_items'] as List<dynamic>? ?? [];
    return InvoiceResultModel(
      nomorFaktur: json['invoice_number'] as String?,
      namaPemasok: json['supplier_name'] as String?,
      daftarItem: itemMentah
          .map((item) => InvoiceItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      ditolak: json['rejected'] as bool? ?? false,
      alasanDitolak: json['rejection_reason'] as String?,
      pakaiDataContoh: json['fallback_used'] as bool? ?? false,
    );
  }
}

// Satu baris barang di faktur.
class InvoiceItemModel {
  final String namaProduk;
  final String? merek;
  final String kategori;
  final int jumlah;
  final String satuan;
  final DateTime? tanggalKedaluwarsa;
  final double hargaNormal;
  final double keyakinan; // 0..1, seberapa yakin OCR membaca baris ini

  InvoiceItemModel({
    required this.namaProduk,
    this.merek,
    required this.kategori,
    required this.jumlah,
    required this.satuan,
    this.tanggalKedaluwarsa,
    required this.hargaNormal,
    required this.keyakinan,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      namaProduk: json['product_name'] as String? ?? '',
      merek: json['brand'] as String?,
      kategori: json['category'] as String? ?? 'General',
      jumlah: json['quantity'] as int? ?? 1,
      satuan: json['unit'] as String? ?? 'pcs',
      // Format dari server YYYY-MM-DD; tryParse agar tidak error bila kosong.
      tanggalKedaluwarsa: DateTime.tryParse(json['expiry_date'] as String? ?? ''),
      hargaNormal: (json['normal_price'] as num?)?.toDouble() ?? 0,
      keyakinan: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }

  int get persenKeyakinan => (keyakinan * 100).round();
}
