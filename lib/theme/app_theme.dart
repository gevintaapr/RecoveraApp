import 'package:flutter/material.dart';

// CATATAN: Menggunakan google_fonts (elemen di luar modul)
// Fungsi: memakai font "Inter", sama dengan desain Recovera lama.
// Alasan: Flutter bawaan hanya punya font Roboto; desain Recovera memakai Inter.
// Cara kerja: GoogleFonts.interTextTheme() membuat TextTheme berfont Inter;
// font diunduh sekali saat pertama tampil lalu disimpan di HP.
import 'package:google_fonts/google_fonts.dart';

// SATU-SATUNYA tempat warna, ukuran font, radius, dan jarak.
// Nilai disamakan dengan desain Recovera lama (../recovera/lib/core/theme).
// Ganti nilai di sini -> seluruh aplikasi ikut berubah.
class AppTheme {
  // Warna dasar Recovera (AppColors lama).
  static const Color warnaUtama = Color(0xFF0077B6); // primary
  static const Color warnaUtamaGelap = Color(0xFF005F92); // primaryDark
  static const Color warnaUtamaTerang = Color(0xFF006CA7); // primaryLight: bawah header auth
  static const Color warnaLabelInput = Color(0xFF475569); // slate-600: label di atas input
  static const Color warnaSekunder = Color(0xFF00B4D8); // secondary
  static const Color warnaAksenMuda = Color(0xFF90E0EF); // accent (gelombang belakang)
  static const Color warnaNavy = Color(0xFF03045E); // darkNavy: judul & teks utama
  static const Color warnaLatar = Color(0xFFF8FAFC); // canvasBg
  static const Color warnaPermukaan = Colors.white;
  static const Color warnaTeks = warnaNavy;
  static const Color warnaTeksRedup = Color(0xFF64748B); // slateText
  static const Color warnaTeksSedang = Color(0xFF475569);
  static const Color warnaGaris = Color(0xFFE2E8F0); // border
  static const Color warnaGarisTegas = Color(0xFFE2E8F0);

  // Status (AppColors lama + pelengkap untuk badge).
  static const Color warnaSukses = Color(0xFF10B981); // success
  static const Color warnaLatarSukses = Color(0xFFECFDF5); // successBg
  static const Color warnaGarisSukses = Color(0xFF6EE7B7); // successBorder
  static const Color warnaGalat = Color(0xFFEF4444); // error
  static const Color warnaGalatTeks = Color(0xFFDC2626); // merah untuk teks/garis tombol (EF4444 hanya 3.8:1)
  static const Color warnaBahaya = warnaGalat; // hati favorit
  static const Color warnaAksen = Color(0xFFF97316); // oranye diskon / peringatan
  static const Color warnaSisaHari = Color(0xFFD97706); // amber "Sisa X hari"
  static const Color warnaLatarInfo = Color(0xFFE0F2FE);
  static const Color warnaTeksInfo = Color(0xFF075985);
  static const Color warnaLatarPeringatan = Color(0xFFFFEDD5);
  static const Color warnaTeksPeringatan = Color(0xFF9A3412);
  static const Color warnaLatarBahaya = Color(0xFFFEF2F2);
  static const Color warnaLatarNetral = Color(0xFFF1F5F9);
  static const Color warnaGelombang = Color(0x7390E0EF); // accent 45%: gelombang belakang header
  static const Color warnaGelombangKiri = Color(0x80006CA7); // primaryLight 50%: gelombang belakang Beranda
  static const Color warnaGelombangKanan = Color(0x9900B4D8); // secondary 60%

  // Kartu produk & Beranda (ProductCard Recovera lama). Warna teks kecil yang
  // terlalu pucat di versi lama digeser satu tingkat lebih gelap agar terbaca (4.5:1).
  static const Color warnaJudulKartu = Color(0xFF0F172A); // slate-900: nama produk
  static const Color warnaJarak = Color(0xFF0369A1); // lama #0284C7 (4.1:1)
  static const Color warnaPitaDiskon = Color(0xFFDC2626); // pita diskon merah
  static const Color warnaSisaMendesak = Color(0xFFDC2626); // <= 3 hari
  static const Color warnaSisaSedang = Color(0xFFB45309); // <= 7 hari, lama #D97706
  static const Color warnaSisaAman = Color(0xFF15803D); // > 7 hari, lama #16A34A
  static const Color warnaGarisCari = Color(0xFFCBD5E1); // garis kolom cari & chip
  static const Color warnaBekuBadge = Color(0xFF0891B2); // badge frozen di foto
  static const Color warnaDinginBadge = Color(0xFF0369A1); // badge chilled di foto
  static const Color warnaRadar = Color(0xFF059669); // ikon "Rekomendasi Terdekat"
  static const Color warnaGarisBadgeSukses = Color(0xFFA7F3D0);
  static const Color warnaTeksBadgeSukses = Color(0xFF047857);
  static const Color warnaPutih18 = Color(0x2EFFFFFF); // tombol & kapsul di header
  static const Color warnaPutih30 = Color(0x4DFFFFFF); // garis tombol di header
  static const Color warnaBayanganKartu = Color(0x08000000); // hitam 3%: bayangan kartu produk

  // Profil (Recovera lama).
  static const Color warnaJudulMenu = Color(0xFF1E293B); // label menu profil
  static const Color warnaIkonBiruMuda = Color(0xFFEFF6FF); // latar ikon menu biru
  static const Color warnaGarisInfo = Color(0xFFBFDBFE); // garis kotak "Alur Saat Ini"
  static const Color warnaLatarUnggah = Color(0xFFF0F9FF); // kotak foto kosong (upload)
  static const Color warnaGarisUnggah = Color(0xFF38BDF8); // garis kotak foto kosong
  static const Color warnaIkonCyanMuda = Color(0xFFE0F7FA); // latar ikon menu lokasi
  static const Color warnaTeksCyan = Color(0xFF0E7490); // subjudul lokasi (secondary digelapkan agar 4.5:1)
  static const Color warnaBayanganAvatar = Color(0x1F000000); // hitam 12%

  // Layar pilih lokasi di peta (Recovera lama).
  static const Color warnaPinPeta = Color(0xFFEA4335); // pin merah
  static const Color warnaLatarPeta = Color(0xFFE5E7EB); // latar saat ubin peta belum termuat
  static const Color warnaPanelPeta = Color(0xEBFFFFFF); // putih 92%: label koordinat di atas peta

  // Detail produk (product_detail_screen Recovera lama).
  static const Color warnaLatarDetail = Color(0xFFFBF8FF); // latar halaman detail
  static const Color warnaPanelLelangAwal = Color(0xFF005D90); // gradien kotak hitung mundur
  static const Color warnaChipHemat = Color(0xFFC2410C); // lama #F97316 (putih hanya 2.8:1)
  static const Color warnaLatarStok = Color(0xFFDCFCE7); // badge "Stok"
  static const Color warnaLatarKedaluwarsa = Color(0xFFFEF3C7); // badge sisa hari (> 3 hari)
  static const Color warnaGarisKedaluwarsa = Color(0xFFFDE68A); // garis pil sisa hari
  static const Color warnaLatarMendesak = Color(0xFFFEE2E2); // badge sisa hari (<= 3 hari)
  static const Color warnaTeksMendesak = Color(0xFF991B1B); // teks di atas latar mendesak
  static const Color warnaBatchHero = Color(0xFF94CCFF); // "BATCH #..." di atas foto gelap
  static const Color warnaTitikJadwal = Color(0xFFF97316); // titik oranye "Turun berikutnya"
  static const Color warnaBayanganBar = Color(0x14000000); // hitam 8%: bayangan bar bawah
  static const Color warnaScrimAtas = Color(0x33000000); // hitam 20%: atas foto hero
  static const Color warnaScrimBawah = Color(0xCC000000); // hitam 80%: bawah foto hero

  // Sisa dari desain kaca; dipertahankan agar widget lama tetap jalan.
  static const Color warnaKaca = Color(0x29FFFFFF); // putih 16%
  static const Color warnaLatarAktif = Color(0x1A0077B6); // biru 10%: pil item nav aktif
  static const Color warnaBayanganNav = Color(0x1F03045E); // navy 12%: bayangan nav mengambang
  static const Color warnaCahayaLogo = Color(0x66FFFFFF); // putih 40%: cahaya di belakang logo
  static const Color warnaGarisKaca = Color(0x59FFFFFF); // putih 35%
  static const Color warnaBarKaca = Colors.white;
  static const Color warnaBayangan = Color(0x260077B6); // bayangan biru tombol utama
  static const double blurKaca = 12;

  // Recovera lama memakai biru solid; "gradien" dibuat satu warna agar widget lama
  // yang memakainya tampil solid.
  static const LinearGradient gradienUtama = LinearGradient(colors: [warnaUtama, warnaUtama]);
  static const LinearGradient gradienHeader = LinearGradient(colors: [warnaUtama, warnaUtama]);
  static const LinearGradient gradienScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0, 0.45],
    colors: [Color(0x0003045E), Color(0xE603045E)],
  );

  // Skala font Recovera lama (textTheme Inter).
  static const double fontMini = 9;
  static const double fontInput = 12; // hint & label input
  static const double fontLabel = 10; // labelSmall
  static const double fontKecil = 11; // bodySmall
  static const double fontNormal = 13; // bodyMedium
  static const double fontSedang = 14; // titleMedium, tombol
  static const double fontSubjudul = 16; // judul AppBar
  static const double fontJudulBagian = 15; // "Rekomendasi Terdekat"
  static const double fontNamaProfil = 20; // nama usaha di Profil
  static const double fontAngkaBento = 24; // angka besar kartu Dasbor
  static const double fontAngkaHitung = 17; // angka hitung mundur di Detail
  static const double fontJudulTransaksi = 18; // judul AppBar transaksi & "Faktur Transaksi B2B"
  static const double fontBesar = 22; // headlineMedium
  static const double fontJudul = 28; // headlineLarge
  static const double fontSambutan = 26; // "Welcome back!" di layar auth
  static const double fontJudulLencana = 24; // "Recovera" di header Register
  static const double fontLabelInput = 12; // label di atas PillTextField

  static const double jarakTipis = 2;
  static const double jarakMini = 4;
  static const double jarakLabel = 6; // padding & radius label kecil
  static const double jarakKecil = 8;
  static const double jarakSedang = 12;
  static const double jarakTepi = 16;
  static const double jarakBesar = 20;
  static const double jarakInput = 14; // padding vertikal input & tombol
  static const double jarakAntarKolom = 14; // jarak antar kolom form auth

  static const double radiusChip = 8;
  static const double radiusSedang = 10; // chip kategori, tombol kecil
  static const double radiusTombol = 12;
  static const double radius = 16; // kartu
  static const double radiusBesar = 20;
  static const double radiusKapsul = 50; // input & tombol kapsul
  static const double radiusNav = 24; // sudut bottom nav mengambang

  static const double tinggiTombol = 48;
  static const double tinggiInput = 48;
  static const double ukuranTombolIkon = 44;
  static const double tinggiChip = 32;
  static const double ukuranTombolKecil = 32;
  static const double ukuranLingkaranLangkah = 28;
  static const double ikonKecil = 16;
  static const double ikonSedang = 20;
  static const double ikonNav = 22; // ikon bottom nav (Recovera lama)
  static const double ikonMata = 18; // ikon tampilkan password
  static const double tandaValid = 26; // lingkaran centang email valid
  static const double ikonCentang = 14;
  static const double ikonLogo = 72;
  static const double logoHeader = 24; // logo kecil di samping tulisan Recovera
  static const double logoHeaderAuth = 96; // logo mark di header Login
  static const double logoLencana = 36; // logo di header Register
  static const double avatarProfil = 88; // avatar melayang di Profil
  static const double tinggiJudulProfil = 72; // baris judul "Profil Saya" di header
  static const double ikonPin = 42; // pin di peta
  static const double ukuranTitik = 5; // titik jadwal & tinggi batang progres
  static const double lebarLabelSpek = 120; // kolom label spesifikasi detail
  static const double kotakPin = 48; // area marker pin
  static const double radiusPeta = 15; // sudut dalam bingkai peta
  static const double jarakAtasTombolPeta = 40; // tombol "Lokasi saya" di atas atribusi OSM
  static const double logoAvatar = 56; // logo di dalam avatar
  static const double tombolHeader = 38; // tombol bulat di header biru (area ketuk 44)
  static const double jarakAuthSisi = 24; // padding kiri-kanan kartu putih auth
  static const double jarakAuthAtas = 64;
  static const double jarakBawahHalaman = 32; // ruang kosong di ujung bawah layar detail // ruang kurva gelombang di atas kartu auth
  static const double gambarKartu = 88; // foto kartu produk (Recovera lama)
  static const double tombolPanah = 28; // tombol panah biru di kartu produk
  static const double gambarPesanan = 64; // foto produk di kartu Riwayat
  static const double kotakIkonStok = 48; // kotak ikon baris stok kedaluwarsa
  static const double fotoStok = 72; // foto kartu Stok penjual
  static const double radiusKartuStok = 18; // sudut kartu Stok penjual
  static const double fontNamaStok = 17; // nama produk di kartu Stok
  static const double fontJudulStok = 26; // "Stok Saya"
  static const double ikonPanah = 15;
  static const double gambarDetail = 240;
  static const double tinggiPratinjauStok = 220; // foto Detail Produk penjual
  static const double tinggiKotakUnggah = 180; // kotak foto kosong di alur upload
  static const double kotakIkonUnggah = 52; // lingkaran ikon di kotak foto kosong
  static const double tinggiGelombang = 28;
  static const double rasioKotakRingkasan = 1.3;

  static const TextStyle gayaHarga = TextStyle(
    fontSize: fontSubjudul,
    fontWeight: FontWeight.w800,
    color: warnaUtama,
  );
  static const TextStyle gayaHargaCoret = TextStyle(
    fontSize: fontKecil,
    color: warnaTeksRedup,
    decoration: TextDecoration.lineThrough,
  );
  static const TextStyle gayaJudul = TextStyle(
    fontSize: fontBesar,
    fontWeight: FontWeight.w700,
    color: warnaNavy,
    letterSpacing: -0.3,
  );
  static const TextStyle gayaSubjudul = TextStyle(
    fontSize: fontSedang,
    fontWeight: FontWeight.w600,
    color: warnaNavy,
  );
  static const TextStyle gayaTeks = TextStyle(fontSize: fontNormal, color: warnaNavy);
  static const TextStyle gayaTeksRedup = TextStyle(fontSize: fontNormal, color: warnaTeksRedup);
  static const TextStyle gayaLabelKapital = TextStyle(
    fontSize: fontLabel,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: warnaTeksRedup,
  );

  // Tema Material untuk GetMaterialApp (mengikuti AppTheme.light Recovera lama).
  static ThemeData get tema {
    final ThemeData dasar = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: warnaUtama,
        primary: warnaUtama,
        onPrimary: warnaPermukaan,
        secondary: warnaSekunder,
        surface: warnaLatar,
        onSurface: warnaNavy,
        error: warnaGalat,
      ),
      scaffoldBackgroundColor: warnaLatar,
    );
    final OutlineInputBorder garisInput = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusKapsul),
      borderSide: const BorderSide(color: warnaGaris),
    );
    final TextStyle gayaTombol = GoogleFonts.inter(fontSize: fontSedang, fontWeight: FontWeight.w700);
    final RoundedRectangleBorder bentukKapsul =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusKapsul));

    return dasar.copyWith(
      textTheme: GoogleFonts.interTextTheme(dasar.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
            fontSize: fontJudul, fontWeight: FontWeight.w700, color: warnaNavy, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.inter(
            fontSize: fontBesar, fontWeight: FontWeight.w700, color: warnaNavy, letterSpacing: -0.3),
        // Recovera lama hampir selalu memakai w600-w700; teks biasa minimal w500
        // supaya tidak terlihat tipis.
        titleLarge: GoogleFonts.inter(fontSize: fontSubjudul, fontWeight: FontWeight.w700, color: warnaNavy),
        titleMedium: GoogleFonts.inter(fontSize: fontSedang, fontWeight: FontWeight.w700, color: warnaNavy),
        titleSmall: GoogleFonts.inter(fontSize: fontNormal, fontWeight: FontWeight.w600, color: warnaNavy),
        bodyLarge: GoogleFonts.inter(fontSize: fontSedang, fontWeight: FontWeight.w500, color: warnaNavy),
        bodyMedium: GoogleFonts.inter(fontSize: fontNormal, fontWeight: FontWeight.w500, color: warnaNavy),
        bodySmall: GoogleFonts.inter(fontSize: fontKecil, fontWeight: FontWeight.w500, color: warnaTeksRedup),
        labelLarge: GoogleFonts.inter(fontSize: fontSedang, fontWeight: FontWeight.w700),
        labelMedium: GoogleFonts.inter(fontSize: fontKecil, fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.inter(
            fontSize: fontLabel, fontWeight: FontWeight.w600, color: warnaTeksRedup, letterSpacing: 0.8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: warnaUtama,
        foregroundColor: warnaPermukaan,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: fontSubjudul,
          fontWeight: FontWeight.w700,
          color: warnaPermukaan,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warnaLatar,
        contentPadding: const EdgeInsets.symmetric(horizontal: jarakBesar, vertical: jarakInput),
        border: garisInput,
        enabledBorder: garisInput,
        focusedBorder: garisInput.copyWith(borderSide: const BorderSide(color: warnaUtama, width: 2)),
        errorBorder: garisInput.copyWith(borderSide: const BorderSide(color: warnaGalat)),
        hintStyle: GoogleFonts.inter(fontSize: fontInput, fontWeight: FontWeight.w500, color: warnaTeksRedup),
        labelStyle: GoogleFonts.inter(fontSize: fontInput, fontWeight: FontWeight.w500, color: warnaTeksRedup),
      ),
      cardTheme: CardThemeData(
        color: warnaPermukaan,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: warnaGaris),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warnaUtama,
          foregroundColor: warnaPermukaan,
          elevation: 4,
          shadowColor: warnaUtama.withValues(alpha: 0.35),
          shape: bentukKapsul,
          padding: const EdgeInsets.symmetric(vertical: jarakInput, horizontal: jarakBesar + jarakMini),
          textStyle: gayaTombol,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: warnaUtama,
          shape: bentukKapsul,
          textStyle: gayaTombol,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: warnaUtama,
          side: const BorderSide(color: warnaUtama),
          shape: bentukKapsul,
          textStyle: gayaTombol,
        ),
      ),
      chipTheme: dasar.chipTheme.copyWith(
        backgroundColor: warnaPermukaan,
        side: const BorderSide(color: warnaGaris),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusKapsul)),
        labelStyle: GoogleFonts.inter(fontSize: fontKecil, color: warnaNavy),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerTheme: const DividerThemeData(color: warnaGaris, thickness: 1, space: 1),
    );
  }
}
