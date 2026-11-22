// Satu notifikasi dari GET /notifications (inbox server).
// Contoh: "Pesanan Baru Masuk!" untuk penjual saat pembeli membeli,
// atau "Pesanan Anda Siap Diambil!" untuk pembeli.
class NotificationModel {
  final int id;
  final String judul;
  final String isi;
  final String tipe; // new_order, order_ready, pickup_reminder, ...
  final bool sudahDibaca;
  final DateTime dibuatPada;
  final int? idPesanan; // dari data.order_id, untuk membuka detail pesanan

  NotificationModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tipe,
    required this.sudahDibaca,
    required this.dibuatPada,
    this.idPesanan,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json['data'] as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: json['id'] as int,
      judul: json['title'] as String? ?? 'Notifikasi',
      isi: json['body'] as String? ?? '',
      tipe: json['type'] as String? ?? '-',
      sudahDibaca: json['is_read'] as bool? ?? false,
      dibuatPada: DateTime.parse(json['created_at'] as String).toLocal(),
      idPesanan: (data['order_id'] as num?)?.toInt(),
    );
  }
}
