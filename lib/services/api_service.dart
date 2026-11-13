import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/listing_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'session_service.dart';

// ApiService = SATU class berisi static method (pola Modul V).
// Semua pemanggilan backend lewat sini; screen tidak memanggil http langsung.
class ApiService {
  // Satu-satunya tempat alamat server.
  // 10.0.2.2 = alamat komputer sendiri bila dibuka dari emulator Android.
  // Untuk HP fisik, ganti dengan IP laptop di jaringan yang sama (mis. http://192.168.1.10:8000)
  // atau alamat ngrok saat demo.
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ===== HELPER (dipakai semua method di bawah) =====

  // Menyusun header. Bila pakaiToken = true, sisipkan
  // Authorization: Bearer <token dari SharedPreferences>.
  static Future<Map<String, String>> _buatHeader({bool pakaiToken = true}) async {
    final Map<String, String> header = {'Content-Type': 'application/json'};
    if (pakaiToken) {
      final String? token = await SessionService.ambilToken();
      if (token != null) {
        header['Authorization'] = 'Bearer $token';
      }
    }
    return header;
  }

  // Menunggu request selesai. Bila server tidak bisa dihubungi
  // atau terlalu lama, lempar pesan yang mudah dipahami.
  static Future<http.Response> _kirim(Future<http.Response> permintaan) async {
    try {
      return await permintaan.timeout(const Duration(seconds: 20));
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server');
    }
  }

  // Membaca response {success, data} / {success, error}.
  // - 401  -> lempar Exception('Sesi berakhir'); layar yang menangkapnya
  //           menghapus sesi lalu kembali ke Login.
  // - gagal -> lempar Exception berisi error.message dari backend.
  // - sukses -> kembalikan isi "data".
  static dynamic _olahResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Sesi berakhir');
    }

    Map<String, dynamic> isiResponse;
    try {
      isiResponse = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Respons server tidak valid (kode ${response.statusCode})');
    }

    if (isiResponse['success'] == true) {
      return isiResponse['data'];
    }

    final Map<String, dynamic>? galat = isiResponse['error'] as Map<String, dynamic>?;
    final String pesan = galat?['message'] as String? ?? 'Terjadi kesalahan';
    throw Exception(pesan);
  }

  // ===== AUTH =====

  // POST /auth/login
  // Login berhasil -> sesi disimpan -> mengembalikan peran ('seller' / 'buyer')
  // untuk menentukan tampilan MainShell.
  static Future<String> masuk({
    required String email,
    required String password,
  }) async {
    final http.Response response = await _kirim(
      http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _buatHeader(pakaiToken: false),
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );

    // Login gagal juga berstatus 401, tetapi artinya email/password salah,
    // bukan sesi berakhir. Jadi ditangani di sini sebelum _olahResponse.
    if (response.statusCode == 401) {
      throw Exception('Email atau password salah');
    }

    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return _simpanSesiDariData(data);
  }

  // POST /auth/register
  // Untuk penjual, backend mewajibkan company_name.
  // Lokasi gudang / usaha boleh kosong; backend memakai nilai bawaan.
  static Future<String> daftar({
    required String email,
    required String password,
    required String peran,
    required String nama,
    String? telepon,
    String? namaPerusahaan,
    String? jenisUsaha,
    String? alamat,
    String? kota,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, dynamic> isiPermintaan = {
      'email': email,
      'password': password,
      'role': peran,
      'name': nama,
    };
    if (telepon != null) isiPermintaan['phone'] = telepon;
    if (alamat != null) isiPermintaan['address'] = alamat;

    if (peran == 'seller') {
      isiPermintaan['company_name'] = namaPerusahaan ?? nama;
      if (kota != null) isiPermintaan['city'] = kota;
      if (latitude != null) isiPermintaan['warehouse_lat'] = latitude;
      if (longitude != null) isiPermintaan['warehouse_lng'] = longitude;
    } else {
      if (jenisUsaha != null) isiPermintaan['business_type'] = jenisUsaha;
      if (latitude != null) isiPermintaan['base_lat'] = latitude;
      if (longitude != null) isiPermintaan['base_lng'] = longitude;
    }

    final http.Response response = await _kirim(
      http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: await _buatHeader(pakaiToken: false),
        body: jsonEncode(isiPermintaan),
      ),
    );

    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return _simpanSesiDariData(data);
  }

  // POST /auth/logout
  // Sesi lokal SELALU dihapus, walaupun server gagal dihubungi,
  // supaya pengguna tetap bisa keluar.
  static Future<void> keluar() async {
    try {
      final http.Response response = await _kirim(
        http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: await _buatHeader(),
        ),
      );
      _olahResponse(response);
    } catch (e) {
      // Gagal logout di server tidak menghalangi logout di HP.
    } finally {
      await SessionService.hapusSesi();
    }
  }

  // GET /profile
  static Future<UserModel> ambilProfil() async {
    final http.Response response = await _kirim(
      http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await _buatHeader(),
      ),
    );

    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  // Data login/register berisi access_token, role, dan name.
  // refresh_token sengaja tidak disimpan (tidak ada refresh otomatis).
  static Future<String> _simpanSesiDariData(Map<String, dynamic> data) async {
    final String peran = data['role'] as String;
    await SessionService.simpanSesi(
      token: data['access_token'] as String,
      peran: peran,
      namaPengguna: data['name'] as String? ?? '',
    );
    return peran;
  }

  // ===== LISTING =====

  // GET /listings
  // Semua filter opsional; yang kosong tidak dikirim.
  // lat/lng/radiusKm dipakai di langkah lokasi.
  static Future<List<ListingModel>> ambilDaftarListing({
    String? kataKunci,
    String? kategori,
    double? lat,
    double? lng,
    double? radiusKm,
    String? urutan, // nearest, cheapest, expiring_soon
  }) async {
    final Map<String, String> parameter = {};
    if (kataKunci != null && kataKunci.isNotEmpty) parameter['search'] = kataKunci;
    if (kategori != null) parameter['category'] = kategori;
    if (lat != null) parameter['lat'] = lat.toString();
    if (lng != null) parameter['lng'] = lng.toString();
    if (radiusKm != null) parameter['radius_km'] = radiusKm.toString();
    if (urutan != null) parameter['sort'] = urutan;

    final Uri alamat = Uri.parse('$baseUrl/listings').replace(
      queryParameters: parameter.isEmpty ? null : parameter,
    );
    final http.Response response = await _kirim(
      http.get(alamat, headers: await _buatHeader()),
    );

    final List<dynamic> data = _olahResponse(response) as List<dynamic>;
    return data
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // GET /listings/{id}
  static Future<ListingModel> ambilDetailListing(int idListing) async {
    final http.Response response = await _kirim(
      http.get(
        Uri.parse('$baseUrl/listings/$idListing'),
        headers: await _buatHeader(),
      ),
    );

    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return ListingModel.fromJson(data);
  }

  // POST /listings/{id}/buy  (khusus pembeli)
  // Harga dikunci server pada detik pembelian (harga lelang saat itu).
  static Future<OrderModel> beliSekarang({
    required int idListing,
    required int jumlah,
  }) async {
    final http.Response response = await _kirim(
      http.post(
        Uri.parse('$baseUrl/listings/$idListing/buy'),
        headers: await _buatHeader(),
        body: jsonEncode({'qty': jumlah}),
      ),
    );

    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return OrderModel.fromJson(data);
  }

  // ===== PENJUAL =====     (langkah: upload penjual, stok)
  // ===== AI =====          (langkah: upload penjual)
  // ===== ORDER =====

  // GET /orders
  // Pembeli: riwayat pembelian. Penjual: pesanan masuk.
  static Future<List<OrderModel>> ambilDaftarPesanan() async {
    final http.Response response = await _kirim(
      http.get(Uri.parse('$baseUrl/orders'), headers: await _buatHeader()),
    );

    final List<dynamic> data = _olahResponse(response) as List<dynamic>;
    return data
        .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // GET /orders/{id}
  static Future<OrderModel> ambilDetailPesanan(int idPesanan) async {
    final http.Response response = await _kirim(
      http.get(Uri.parse('$baseUrl/orders/$idPesanan'), headers: await _buatHeader()),
    );

    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return OrderModel.fromJson(data);
  }

  // (ubahStatusPesanan ditambahkan di langkah "pesanan masuk" penjual)
  // ===== NOTIFIKASI =====  (langkah: notifikasi)
}
