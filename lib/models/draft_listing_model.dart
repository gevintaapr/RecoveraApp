import 'dart:typed_data';

import 'package:hive/hive.dart';

// File ini dibuat otomatis oleh build_runner (Modul VI):
//   dart run build_runner build --delete-conflicting-outputs
part 'draft_listing_model.g.dart';

// Draft upload penjual yang disimpan di HP (Hive box 'draft_listings').
// Dipakai saat form belum lengkap atau server tidak bisa dihubungi.
// Draft TIDAK dikirim otomatis: penjual membukanya lagi lalu menekan
// "Lanjut" -> rekomendasi harga -> "Terbitkan".
@HiveType(typeId: 2)
class DraftListingModel {
  @HiveField(0)
  final String idDraft; // kunci di Hive (waktu dibuat, dalam milidetik)
  @HiveField(1)
  final String namaProduk;
  @HiveField(2)
  final String? merek;
  @HiveField(3)
  final String kategori;
  @HiveField(4)
  final String jenisPenyimpanan; // ambient, chilled, frozen
  @HiveField(5)
  final String satuan;
  @HiveField(6)
  final int jumlah;
  @HiveField(7)
  final double hargaNormal;
  @HiveField(8)
  final double hargaMinimum;
  @HiveField(9)
  final DateTime tanggalKedaluwarsa;
  @HiveField(10)
  final String nomorBatch;
  @HiveField(11)
  final Uint8List? gambarProduk; // foto produk (sudah dikecilkan saat dipilih)
  @HiveField(12)
  final DateTime waktuDisimpan;

  DraftListingModel({
    required this.idDraft,
    required this.namaProduk,
    this.merek,
    required this.kategori,
    required this.jenisPenyimpanan,
    required this.satuan,
    required this.jumlah,
    required this.hargaNormal,
    required this.hargaMinimum,
    required this.tanggalKedaluwarsa,
    required this.nomorBatch,
    this.gambarProduk,
    required this.waktuDisimpan,
  });
}
