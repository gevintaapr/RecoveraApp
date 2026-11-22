// Rekomendasi harga awal lelang dari
// POST /listings/seller/inventory/{id}/recommendation.
// Dihitung server: model LightGBM (source = "ml"), atau rumus cadangan
// (source = "rule") bila model tidak tersedia. Flutter hanya menampilkan.
class PriceAdviceModel {
  final double hargaSaran;
  final double persenDiskon;
  final String alasan; // penjelasan singkat dari server
  final String sumber; // 'ml' atau 'rule'
  final String? versiModel;
  // Rentang harga awal yang dianggap wajar (80%–120% dari saran).
  final double? batasBawah;
  final double? batasAtas;
  // true bila harga awal draft di luar rentang -> penjual harus menyetujui peringatan.
  final bool perluPeringatan;

  PriceAdviceModel({
    required this.hargaSaran,
    required this.persenDiskon,
    required this.alasan,
    required this.sumber,
    this.versiModel,
    this.batasBawah,
    this.batasAtas,
    required this.perluPeringatan,
  });

  // Bentuk data: {recommendation: {...}, price_warning, accepted_range: {minimum, maximum}}
  factory PriceAdviceModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> saran =
        json['recommendation'] as Map<String, dynamic>? ?? {};
    final Map<String, dynamic>? rentang =
        json['accepted_range'] as Map<String, dynamic>?;

    return PriceAdviceModel(
      hargaSaran: (saran['suggested_price'] as num?)?.toDouble() ?? 0,
      persenDiskon: (saran['discount_pct'] as num?)?.toDouble() ?? 0,
      alasan: saran['rationale'] as String? ?? '',
      sumber: saran['source'] as String? ?? 'rule',
      versiModel: saran['model_version'] as String?,
      batasBawah: (rentang?['minimum'] as num?)?.toDouble(),
      batasAtas: (rentang?['maximum'] as num?)?.toDouble(),
      perluPeringatan: json['price_warning'] as bool? ?? false,
    );
  }

  bool get dariModelAi => sumber == 'ml';
}
