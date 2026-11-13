// Model pesanan dari POST /listings/{id}/buy, GET /orders, dan GET /orders/{id}.
// Status dari server: paid -> in_progress -> completed (diubah oleh penjual).
class OrderModel {
  final int id;
  final int idListing;
  final String namaProduk;
  final String? kategori;
  final String? urlGambar;
  final String? namaPenjual;
  final String? namaPembeli;
  final int jumlah;
  final double hargaSatuan;
  final double totalHarga;
  final String status;
  final DateTime dibuatPada;
  final String? alamatGudang;

  OrderModel({
    required this.id,
    required this.idListing,
    required this.namaProduk,
    this.kategori,
    this.urlGambar,
    this.namaPenjual,
    this.namaPembeli,
    required this.jumlah,
    required this.hargaSatuan,
    required this.totalHarga,
    required this.status,
    required this.dibuatPada,
    this.alamatGudang,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Detail produk ada di objek "product_detail".
    final Map<String, dynamic> detail =
        json['product_detail'] as Map<String, dynamic>? ?? {};

    return OrderModel(
      id: json['id'] as int,
      idListing: json['listing_id'] as int,
      namaProduk: detail['product_name'] as String? ?? 'Produk',
      kategori: detail['category'] as String?,
      urlGambar: (json['image_url'] ?? detail['image_url']) as String?,
      namaPenjual: json['seller_name'] as String?,
      namaPembeli: json['buyer_name'] as String?,
      jumlah: json['qty'] as int,
      hargaSatuan: (json['final_unit_price'] as num).toDouble(),
      totalHarga: (json['total_price'] as num).toDouble(),
      status: json['status'] as String? ?? 'paid',
      dibuatPada: DateTime.parse(json['created_at'] as String).toLocal(),
      alamatGudang: detail['warehouse_address'] as String?,
    );
  }

  // Teks status yang ditampilkan ke pengguna.
  String get labelStatus {
    switch (status) {
      case 'paid':
        return 'Menunggu disiapkan';
      case 'in_progress':
        return 'Siap diambil';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }
}
