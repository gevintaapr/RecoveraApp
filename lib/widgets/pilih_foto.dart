import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_theme.dart';

// Kotak pratinjau foto + tombol Kamera / Galeri.
// Dipakai di layar upload faktur (foto faktur) dan form listing (foto produk).
// Foto yang dipilih dikirim balik ke layar lewat onFotoDipilih;
// layar yang menyimpan foto itu di state-nya (setState).
class PilihFoto extends StatelessWidget {
  final Uint8List? gambar;
  final String teksKosong;
  final String? pesanGalat;
  final void Function(Uint8List isiFile, String namaFile) onFotoDipilih;

  const PilihFoto({
    super.key,
    required this.gambar,
    required this.teksKosong,
    required this.onFotoDipilih,
    this.pesanGalat,
  });

  // CATATAN: Menggunakan image_picker (elemen di luar modul)
  // Fungsi: mengambil foto dari kamera atau galeri HP.
  // Alasan: faktur dan foto produk harus difoto langsung oleh penjual;
  //         Modul I–VIII tidak membahas akses kamera/galeri.
  // Cara kerja: ImagePicker membuka kamera/galeri, mengembalikan file (XFile)
  //         yang sudah dikecilkan (maxWidth, imageQuality) agar < 2 MB,
  //         lalu isinya dibaca sebagai bytes untuk pratinjau dan upload.
  Future<void> _ambilFoto(BuildContext context, ImageSource sumber) async {
    try {
      final XFile? file = await ImagePicker().pickImage(
        source: sumber,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (file == null) return; // pengguna batal memilih
      final Uint8List isi = await file.readAsBytes();
      onFotoDipilih(isi, file.name);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera / galeri tidak dapat dibuka')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kotak foto gaya Upload Stok Recovera lama: kosong = biru muda bergaris
        // (ketuk untuk buka galeri), sudah ada foto = garis hijau.
        Material(
          color: gambar == null ? AppTheme.warnaLatarUnggah : AppTheme.warnaPermukaan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusKartuStok),
            side: BorderSide(color: gambar == null ? AppTheme.warnaGarisUnggah : AppTheme.warnaSukses, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: gambar == null ? () => _ambilFoto(context, ImageSource.gallery) : null,
            child: SizedBox(
              height: gambar == null ? AppTheme.tinggiKotakUnggah : AppTheme.tinggiPratinjauStok,
              child: gambar == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: AppTheme.kotakIkonUnggah,
                          height: AppTheme.kotakIkonUnggah,
                          decoration: const BoxDecoration(color: AppTheme.warnaLatarInfo, shape: BoxShape.circle),
                          child: const Icon(Icons.photo_library_outlined, size: AppTheme.ikonNav, color: AppTheme.warnaJarak),
                        ),
                        const SizedBox(height: AppTheme.radiusSedang),
                        Text(
                          teksKosong,
                          style: const TextStyle(fontSize: AppTheme.fontSedang, fontWeight: FontWeight.w700, color: AppTheme.warnaNavy),
                        ),
                        const SizedBox(height: AppTheme.jarakMini),
                        const Text(
                          'Ketuk untuk pilih dari galeri, atau pakai tombol di bawah',
                          style: TextStyle(fontSize: AppTheme.fontInput, color: AppTheme.warnaTeksSedang),
                        ),
                      ],
                    )
                  : Image.memory(gambar!, fit: BoxFit.contain),
            ),
          ),
        ),
        if (pesanGalat != null)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.jarakKecil),
            child: Text(pesanGalat!, style: const TextStyle(fontSize: AppTheme.fontKecil, color: AppTheme.warnaGalatTeks)),
          ),
        const SizedBox(height: AppTheme.jarakKecil),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _ambilFoto(context, ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Kamera'),
              ),
            ),
            const SizedBox(width: AppTheme.jarakKecil),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _ambilFoto(context, ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galeri'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
