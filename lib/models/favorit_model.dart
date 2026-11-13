import 'package:hive/hive.dart';

import 'listing_model.dart';

// File ini dibuat otomatis oleh build_runner (Modul VI):
//   dart run build_runner build
part 'favorit_model.g.dart';

// Satu listing lelang yang disimpan pembeli ke HP (Hive box 'favorit_listing').
// Yang disimpan adalah "foto" data saat itu; harga terbaru diambil lagi
// dari server ketika favorit dibuka ke halaman detail.
@HiveType(typeId: 0)
class FavoritModel {
  @HiveField(0)
  final int idListing;

  @HiveField(1)
  final String namaProduk;

  @HiveField(2)
  final String? urlGambar;

  @HiveField(3)
  final double hargaSaatDisimpan;

  @HiveField(4)
  final double hargaNormal;

  @HiveField(5)
  final DateTime lelangBerakhir;

  @HiveField(6)
  final String? namaPenjual;

  @HiveField(7)
  final DateTime waktuDisimpan;

  FavoritModel({
    required this.idListing,
    required this.namaProduk,
    this.urlGambar,
    required this.hargaSaatDisimpan,
    required this.hargaNormal,
    required this.lelangBerakhir,
    this.namaPenjual,
    required this.waktuDisimpan,
  });

  // Membuat favorit dari listing yang sedang dilihat.
  factory FavoritModel.dariListing(ListingModel listing) {
    return FavoritModel(
      idListing: listing.id,
      namaProduk: listing.namaProduk,
      urlGambar: listing.urlGambar,
      hargaSaatDisimpan: listing.hargaSekarang,
      hargaNormal: listing.hargaNormal,
      lelangBerakhir: listing.lelangBerakhir,
      namaPenjual: listing.namaPenjual,
      waktuDisimpan: DateTime.now(),
    );
  }

  bool get lelangSudahBerakhir => DateTime.now().isAfter(lelangBerakhir);
}
