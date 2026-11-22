import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/invoice_result_model.dart';
import '../models/listing_model.dart';
import '../models/notification_model.dart';
import '../models/order_model.dart';
import '../models/price_advice_model.dart';
import '../models/user_model.dart';
import 'session_service.dart';

// ApiService = SATU class berisi static method (pola Modul V).
// Semua pemanggilan backend lewat sini; screen tidak memanggil http langsung.
class ApiService {
  // Satu-satunya tempat alamat server.
  // 127.0.0.1 = "komputer ini sendiri", dipakai di semua perangkat:
  // - Chrome / Windows: backend memang ada di laptop yang sama.
  // - HP (kabel USB) atau emulator: jalankan dulu di laptop
  //     adb reverse tcp:8000 tcp:8000
  //   agar 127.0.0.1:8000 di HP diteruskan lewat USB ke port 8000 laptop.
  //   Tidak perlu Wi-Fi yang sama dan tidak perlu tahu IP laptop.
  // Saat demo dengan ngrok, cukup ganti baris ini dengan alamat ngrok.
  static const String baseUrl = 'http://127.0.0.1:8000';

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

  // ===== PENJUAL =====

  // GET /listings/seller/inventory
  // Semua listing milik penjual (draft, aktif, terjual, kedaluwarsa), terbaru di atas.
  static Future<List<ListingModel>> ambilInventaris() async {
    final http.Response response = await _kirim(
      http.get(Uri.parse('$baseUrl/listings/seller/inventory'), headers: await _buatHeader()),
    );

    final List<dynamic> data = _olahResponse(response) as List<dynamic>;
    return data
        .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // PATCH /listings/{id}
  // Mengubah stok dan/atau harga minimum listing yang sudah terbit.
  // Kolom yang null tidak dikirim (tidak diubah).
  static Future<ListingModel> ubahListing(
    int idListing, {
    int? jumlah,
    double? hargaMinimum,
  }) async {
    final Map<String, dynamic> isiPermintaan = {};
    if (jumlah != null) isiPermintaan['qty'] = jumlah;
    if (hargaMinimum != null) isiPermintaan['min_price'] = hargaMinimum;

    final http.Response response = await _kirim(
      http.patch(
        Uri.parse('$baseUrl/listings/$idListing'),
        headers: await _buatHeader(),
        body: jsonEncode(isiPermintaan),
      ),
    );

    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return ListingModel.fromJson(data);
  }

  // POST /listings/seller/inventory/drafts
  // Membuat produk + listing berstatus "draft" di server.
  // Server langsung mengisi harga awal = harga saran AI.
  static Future<ListingModel> buatDraft({
    required String namaProduk,
    String? merek,
    required String kategori,
    required String jenisPenyimpanan,
    required String satuan,
    required String urlGambar,
    required String nomorBatch,
    required int jumlah,
    required double hargaNormal,
    required double hargaMinimum,
    required DateTime tanggalKedaluwarsa,
  }) async {
    final String tanggal = tanggalKedaluwarsa.toIso8601String().substring(0, 10); // YYYY-MM-DD
    final Map<String, dynamic> isiPermintaan = {
      // SKU wajib di backend; dibuat otomatis agar penjual tidak perlu mengisi.
      'sku': 'SKU-${DateTime.now().millisecondsSinceEpoch}',
      'name': namaProduk,
      'category': kategori,
      'storage_type': jenisPenyimpanan,
      'default_unit': satuan,
      'image_url': urlGambar,
      'batch_number': nomorBatch,
      'qty': jumlah,
      'normal_price': hargaNormal,
      'min_price': hargaMinimum,
      'expiry_date': tanggal,
    };
    if (merek != null && merek.isNotEmpty) isiPermintaan['brand'] = merek;

    final http.Response response = await _kirim(
      http.post(
        Uri.parse('$baseUrl/listings/seller/inventory/drafts'),
        headers: await _buatHeader(),
        body: jsonEncode(isiPermintaan),
      ),
    );

    // Data: {listing, validation, price_recommendation}; yang dipakai listing-nya.
    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return ListingModel.fromJson(data['listing'] as Map<String, dynamic>);
  }

  // POST /listings/seller/inventory/{id}/recommendation
  static Future<PriceAdviceModel> ambilRekomendasiHarga(int idListing) async {
    final http.Response response = await _kirim(
      http.post(
        Uri.parse('$baseUrl/listings/seller/inventory/$idListing/recommendation'),
        headers: await _buatHeader(),
      ),
    );

    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return PriceAdviceModel.fromJson(data);
  }

  // POST /listings/seller/inventory/{id}/publish
  // Draft menjadi "active" dan tampil di katalog pembeli.
  // setujuiPeringatan = true bila harga awal di luar rentang saran
  // dan penjual sudah menyetujui peringatannya.
  static Future<ListingModel> terbitkanListing(
    int idListing, {
    bool setujuiPeringatan = false,
  }) async {
    final http.Response response = await _kirim(
      http.post(
        Uri.parse('$baseUrl/listings/seller/inventory/$idListing/publish'),
        headers: await _buatHeader(),
        body: jsonEncode({'acknowledge_price_warning': setujuiPeringatan}),
      ),
    );

    final Map<String, dynamic> data = _olahResponse(response) as Map<String, dynamic>;
    return ListingModel.fromJson(data);
  }

  // DELETE /listings/seller/inventory/{id}
  // Menghapus produk berstatus draft dari inventaris penjual.
  static Future<void> hapusDraft(int idListing) async {
    final http.Response response = await _kirim(
      http.delete(
        Uri.parse('$baseUrl/listings/seller/inventory/$idListing'),
        headers: await _buatHeader(),
      ),
    );
    _olahResponse(response);
  }

  // PATCH /listings/seller/inventory/{id}
  // Memperbarui data draft (nama, stok, harga, tanggal, nomor batch).
  static Future<ListingModel> ubahDraft(
    int idListing,
    Map<String, dynamic> data,
  ) async {
    final http.Response response = await _kirim(
      http.patch(
        Uri.parse('$baseUrl/listings/seller/inventory/$idListing'),
        headers: await _buatHeader(),
        body: jsonEncode(data),
      ),
    );
    final Map<String, dynamic> hasil =
        _olahResponse(response) as Map<String, dynamic>;
    final Map<String, dynamic> listingJson =
        (hasil['listing'] ?? hasil) as Map<String, dynamic>;
    return ListingModel.fromJson(listingJson);
  }

  // POST /products/upload-image (multipart, field "file")
  // Satu-satunya endpoint /products yang dipakai: foto produk diunggah
  // ke penyimpanan server, hasilnya image_url untuk membuat draft.
  static Future<String> unggahGambarProduk({
    required Uint8List isiFile,
    required String namaFile,
  }) async {
    final Map<String, dynamic> data = await _kirimMultipart(
      alamat: '$baseUrl/products/upload-image',
      isiFile: isiFile,
      namaFile: namaFile,
    );
    return data['image_url'] as String;
  }

  // ===== AI =====

  // POST /ai/invoice (multipart, field "file")
  // Foto faktur dibaca server (OCR), hasilnya daftar barang untuk mengisi form.
  static Future<InvoiceResultModel> unggahFaktur({
    required Uint8List isiFile,
    required String namaFile,
  }) async {
    final Map<String, dynamic> data = await _kirimMultipart(
      alamat: '$baseUrl/ai/invoice',
      isiFile: isiFile,
      namaFile: namaFile,
    );
    return InvoiceResultModel.fromJson(data);
  }

  // CATATAN: Menggunakan http.MultipartRequest (elemen di luar modul)
  // Fungsi: mengirim file gambar (faktur / foto produk) ke backend.
  // Alasan: http.post di Modul V hanya mengirim teks/JSON, sedangkan
  //         endpoint upload meminta form-data berisi file.
  // Cara kerja: request dibuat, token dipasang di header, file ditempel
  //         sebagai field "file", lalu dikirim; jawabannya dibaca seperti
  //         response biasa lewat _olahResponse.
  static Future<Map<String, dynamic>> _kirimMultipart({
    required String alamat,
    required Uint8List isiFile,
    required String namaFile,
  }) async {
    final http.MultipartRequest permintaan =
        http.MultipartRequest('POST', Uri.parse(alamat));
    final String? token = await SessionService.ambilToken();
    if (token != null) permintaan.headers['Authorization'] = 'Bearer $token';

    // Backend memeriksa jenis file harus "image/...", jadi jenisnya ditulis
    // jelas (MediaType dari package http_parser, bawaan package http).
    final bool filePng = namaFile.toLowerCase().endsWith('.png');
    permintaan.files.add(http.MultipartFile.fromBytes(
      'file',
      isiFile,
      filename: namaFile,
      contentType: MediaType('image', filePng ? 'png' : 'jpeg'),
    ));

    // OCR bisa lama, jadi batas waktunya lebih panjang dari request biasa.
    http.Response response;
    try {
      final http.StreamedResponse hasilStream =
          await permintaan.send().timeout(const Duration(seconds: 60));
      response = await http.Response.fromStream(hasilStream);
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server');
    }
    return _olahResponse(response) as Map<String, dynamic>;
  }

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

  // PATCH /orders/{id}/status  (khusus penjual)
  // Urutan yang diizinkan server: paid -> in_progress -> completed.
  static Future<void> ubahStatusPesanan(int idPesanan, String statusBaru) async {
    final http.Response response = await _kirim(
      http.patch(
        Uri.parse('$baseUrl/orders/$idPesanan/status'),
        headers: await _buatHeader(),
        body: jsonEncode({'status': statusBaru}),
      ),
    );
    _olahResponse(response);
  }

  // POST /orders/{id}/remind-seller  (khusus pembeli)
  // Mengirim notifikasi pengingat ke penjual. Hanya untuk status "paid";
  // server menolak bila pengingat terakhir belum lewat 3 jam (pesan error dari server).
  static Future<void> ingatkanPenjual(int idPesanan) async {
    final http.Response response = await _kirim(
      http.post(
        Uri.parse('$baseUrl/orders/$idPesanan/remind-seller'),
        headers: await _buatHeader(),
      ),
    );
    _olahResponse(response);
  }

  // POST /orders/{id}/remind-buyer  (khusus penjual)
  // Mengirim notifikasi pengingat ke pembeli agar mengambil barang (status in_progress).
  static Future<void> ingatkanPembeli(int idPesanan) async {
    final http.Response response = await _kirim(
      http.post(
        Uri.parse('$baseUrl/orders/$idPesanan/remind-buyer'),
        headers: await _buatHeader(),
      ),
    );
    _olahResponse(response);
  }

  // ===== NOTIFIKASI =====

  // GET /notifications -> inbox milik user yang login, terbaru di atas.
  static Future<List<NotificationModel>> ambilNotifikasi() async {
    final http.Response response = await _kirim(
      http.get(Uri.parse('$baseUrl/notifications'), headers: await _buatHeader()),
    );

    final List<dynamic> data = _olahResponse(response) as List<dynamic>;
    return data
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // PATCH /notifications/{id}/read
  static Future<void> tandaiNotifikasiDibaca(int idNotifikasi) async {
    final http.Response response = await _kirim(
      http.patch(
        Uri.parse('$baseUrl/notifications/$idNotifikasi/read'),
        headers: await _buatHeader(),
      ),
    );
    _olahResponse(response);
  }
}
