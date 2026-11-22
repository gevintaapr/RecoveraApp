import 'listing_model.dart';

// Satu notifikasi dari GET /notifications (inbox server).
// Contoh: "Pesanan Baru Masuk!" untuk penjual saat pembeli membeli,
// atau "Pesanan Anda Siap Diambil!" untuk pembeli (T8).
class NotificationModel {
  final int id;
  final String judul;
  final String isi;
  final String tipe; // new_order, order_ready, pickup_reminder, new_listing, ...
  final bool sudahDibaca;
  final DateTime dibuatPada;
  final int? idPesanan; // dari data.order_id
  final int? idListing; // dari data.listing_id

  NotificationModel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tipe,
    required this.sudahDibaca,
    required this.dibuatPada,
    this.idPesanan,
    this.idListing,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? {};
    return NotificationModel(
      id: json['id'] as int,
      judul: json['title'] as String? ?? 'Notifikasi',
      isi: json['body'] as String? ?? '',
      tipe: json['type'] as String? ?? '-',
      sudahDibaca: json['is_read'] as bool? ?? false,
      dibuatPada: DateTime.parse(json['created_at'] as String).toLocal(),
      idPesanan: (data['order_id'] as num?)?.toInt(),
      idListing: (data['listing_id'] as num?)?.toInt(),
    );
  }

  // Waktu relatif: "Baru saja", "5 menit lalu", "2 jam lalu", atau tanggal (T8).
  String get waktuRelatif {
    final Duration selisih = DateTime.now().difference(dibuatPada);
    if (selisih.inMinutes < 1) {
      return 'Baru saja';
    } else if (selisih.inMinutes < 60) {
      return '${selisih.inMinutes} menit lalu';
    } else if (selisih.inHours < 24) {
      return '${selisih.inHours} jam lalu';
    } else if (selisih.inDays < 7) {
      return '${selisih.inDays} hari lalu';
    } else {
      return '${ListingModel.formatTanggal(dibuatPada)}, ${ListingModel.formatJam(dibuatPada)}';
    }
  }
}
