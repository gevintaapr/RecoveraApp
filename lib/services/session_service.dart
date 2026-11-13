import 'package:shared_preferences/shared_preferences.dart';

// SessionService: menyimpan sesi login di SharedPreferences (Modul VI).
// Catatan keamanan versi praktikum: token disimpan sebagai teks biasa,
// bukan di penyimpanan terenkripsi.
class SessionService {
  static const String _kunciToken = 'access_token';
  static const String _kunciPeran = 'role';
  static const String _kunciNamaPengguna = 'user_name';
  static const String _kunciSudahLogin = 'is_logged_in';
  static const String _kunciIdNotifTerakhir = 'last_notif_id';

  // Dipanggil setelah login / register berhasil.
  static Future<void> simpanSesi({
    required String token,
    required String peran,
    required String namaPengguna,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kunciToken, token);
    await prefs.setString(_kunciPeran, peran);
    await prefs.setString(_kunciNamaPengguna, namaPengguna);
    await prefs.setBool(_kunciSudahLogin, true);
  }

  static Future<String?> ambilToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kunciToken);
  }

  // Hasilnya 'seller' atau 'buyer' (null bila belum login).
  static Future<String?> ambilPeran() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kunciPeran);
  }

  static Future<String?> ambilNamaPengguna() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kunciNamaPengguna);
  }

  // Dipakai splash screen untuk memilih: ke Login atau langsung ke MainShell.
  static Future<bool> sudahLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kunciSudahLogin) ?? false;
  }

  // ID notifikasi server terakhir yang sudah dimunculkan sebagai pop-up.
  static Future<int> ambilIdNotifTerakhir() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kunciIdNotifTerakhir) ?? 0;
  }

  static Future<void> simpanIdNotifTerakhir(int idNotif) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kunciIdNotifTerakhir, idNotif);
  }

  // Dipanggil saat logout atau sesi berakhir (401).
  // last_notif_id ikut dihapus agar akun berikutnya mulai dari nol.
  static Future<void> hapusSesi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kunciToken);
    await prefs.remove(_kunciPeran);
    await prefs.remove(_kunciNamaPengguna);
    await prefs.remove(_kunciSudahLogin);
    await prefs.remove(_kunciIdNotifTerakhir);
  }
}
