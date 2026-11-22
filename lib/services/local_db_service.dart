import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/draft_listing_model.dart';
import '../models/favorit_model.dart';
import '../models/listing_model.dart';
import '../models/order_model.dart';

// LocalDbService: SATU-SATUNYA tempat yang menyentuh Hive (Modul VI).
// Screen dan controller memanggil method di sini, tidak membuka box sendiri.
class LocalDbService {
  static const String _namaBoxFavorit = 'favorit_listing';
  static const String _namaBoxCacheKatalog = 'listings_cache';
  static const String _namaBoxDraft = 'draft_listings';
  static const String _namaBoxCachePesanan = 'orders_cache';

  // Dipanggil sekali di main.dart sebelum runApp.
  static Future<void> init() async {
    await Hive.initFlutter();
    // Adapter hasil build_runner (favorit_model.g.dart).
    Hive.registerAdapter(FavoritModelAdapter());
    Hive.registerAdapter(ListingModelAdapter());
    Hive.registerAdapter(DraftListingModelAdapter());
    Hive.registerAdapter(OrderModelAdapter());
    await Hive.openBox<FavoritModel>(_namaBoxFavorit);
    await Hive.openBox<ListingModel>(_namaBoxCacheKatalog);
    await Hive.openBox<DraftListingModel>(_namaBoxDraft);
    await Hive.openBox<OrderModel>(_namaBoxCachePesanan);
  }

  static Box<FavoritModel> get _boxFavorit =>
      Hive.box<FavoritModel>(_namaBoxFavorit);

  static Box<ListingModel> get _boxCacheKatalog =>
      Hive.box<ListingModel>(_namaBoxCacheKatalog);

  // ===== CACHE KATALOG =====

  // Menyimpan katalog terakhir dari server. Isi lama dihapus dulu,
  // jadi cache selalu sama dengan hasil terakhir yang berhasil dimuat.
  static Future<void> simpanCacheKatalog(List<ListingModel> daftarListing) async {
    await _boxCacheKatalog.clear();
    await _boxCacheKatalog.addAll(daftarListing);
  }

  // Dipakai saat server tidak bisa dihubungi (tampil dengan label "Data offline").
  static List<ListingModel> ambilCacheKatalog() {
    return _boxCacheKatalog.values.toList();
  }

  // ===== CACHE PESANAN =====

  static Box<OrderModel> get _boxCachePesanan =>
      Hive.box<OrderModel>(_namaBoxCachePesanan);

  // Menyimpan daftar pesanan terakhir dari server (isi lama diganti).
  static Future<void> simpanCachePesanan(List<OrderModel> daftarPesanan) async {
    await _boxCachePesanan.clear();
    await _boxCachePesanan.addAll(daftarPesanan);
  }

  // Dipakai saat server tidak bisa dihubungi (tampil dengan label "Data offline").
  static List<OrderModel> ambilCachePesanan() {
    return _boxCachePesanan.values.toList();
  }

  // Dipanggil saat logout / sesi berakhir, supaya pesanan akun ini
  // tidak terlihat oleh akun lain yang masuk di HP yang sama.
  static Future<void> hapusCachePesanan() async {
    await _boxCachePesanan.clear();
  }

  // ===== FAVORIT =====

  // Semua favorit, yang terbaru disimpan tampil paling atas.
  static List<FavoritModel> ambilSemuaFavorit() {
    final List<FavoritModel> daftar = _boxFavorit.values.toList();
    daftar.sort((a, b) => b.waktuDisimpan.compareTo(a.waktuDisimpan));
    return daftar;
  }

  // Kunci = id listing, jadi listing yang sama tidak tersimpan dua kali.
  static Future<void> simpanFavorit(FavoritModel favorit) async {
    await _boxFavorit.put(favorit.idListing, favorit);
  }

  static Future<void> hapusFavorit(int idListing) async {
    await _boxFavorit.delete(idListing);
  }

  // ===== DRAFT PENJUAL =====

  static Box<DraftListingModel> get _boxDraft =>
      Hive.box<DraftListingModel>(_namaBoxDraft);

  // Dipakai layar dengan ValueListenableBuilder (Modul VI): setiap draft
  // disimpan / dihapus, daftar draft di layar ikut berubah sendiri.
  static ValueListenable<Box<DraftListingModel>> pantauDraft() {
    return _boxDraft.listenable();
  }

  // Draft terbaru di atas.
  static List<DraftListingModel> ambilSemuaDraft() {
    final List<DraftListingModel> daftar = _boxDraft.values.toList();
    daftar.sort((a, b) => b.waktuDisimpan.compareTo(a.waktuDisimpan));
    return daftar;
  }

  // Kunci = idDraft, jadi menyimpan draft yang sama akan menimpa versi lamanya.
  static Future<void> simpanDraft(DraftListingModel draft) async {
    await _boxDraft.put(draft.idDraft, draft);
  }

  static Future<void> hapusDraft(String idDraft) async {
    await _boxDraft.delete(idDraft);
  }

  // (skor game ditambahkan di langkahnya)
}
