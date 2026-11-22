import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Kolom-kolom form data produk (Modul III: TextFormField + validator, Dropdown).
// Isinya disimpan oleh ListingFormScreen (controller + state pilihan);
// widget ini hanya menampilkan dan memberi tahu bila pilihan berubah.
class FormDataProduk extends StatelessWidget {
  static const List<String> daftarKategori = [
    'Dairy', 'Frozen', 'Flour & Grain', 'Oil & Condiment', 'Beverage', 'Canned & Preserved', 'General',
  ];
  static const Map<String, String> daftarPenyimpanan = {
    'ambient': 'Suhu ruang', 'chilled': 'Dingin', 'frozen': 'Beku',
  };
  static const List<String> daftarSatuan = ['pcs', 'kg', 'liter', 'box', 'karton', 'pack'];

  final TextEditingController namaController;
  final TextEditingController merekController;
  final TextEditingController jumlahController;
  final TextEditingController hargaNormalController;
  final TextEditingController hargaMinimumController;
  final TextEditingController nomorBatchController;
  final TextEditingController tanggalController;
  final String kategori;
  final String penyimpanan;
  final String satuan;
  final ValueChanged<String> onKategoriBerubah;
  final ValueChanged<String> onPenyimpananBerubah;
  final ValueChanged<String> onSatuanBerubah;
  final VoidCallback onPilihTanggal;

  const FormDataProduk({
    super.key,
    required this.namaController,
    required this.merekController,
    required this.jumlahController,
    required this.hargaNormalController,
    required this.hargaMinimumController,
    required this.nomorBatchController,
    required this.tanggalController,
    required this.kategori,
    required this.penyimpanan,
    required this.satuan,
    required this.onKategoriBerubah,
    required this.onPenyimpananBerubah,
    required this.onSatuanBerubah,
    required this.onPilihTanggal,
  });

  String? _wajibIsi(String? nilai, String namaKolom) {
    return (nilai == null || nilai.trim().isEmpty) ? '$namaKolom wajib diisi' : null;
  }

  String? _wajibAngka(String? nilai) {
    final double? angka = double.tryParse(nilai ?? '');
    if (angka == null || angka <= 0) return 'Isi angka lebih dari 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const SizedBox jarak = SizedBox(height: AppTheme.jarakSedang);
    return Column(
      children: [
        TextFormField(
          controller: namaController,
          decoration: const InputDecoration(labelText: 'Nama produk'),
          validator: (nilai) => _wajibIsi(nilai, 'Nama produk'),
        ),
        jarak,
        TextFormField(
          controller: merekController,
          decoration: const InputDecoration(labelText: 'Merek (opsional)'),
        ),
        jarak,
        DropdownButtonFormField<String>(
          initialValue: kategori,
          decoration: const InputDecoration(labelText: 'Kategori'),
          items: daftarKategori.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
          onChanged: (nilai) => onKategoriBerubah(nilai!),
        ),
        jarak,
        DropdownButtonFormField<String>(
          initialValue: penyimpanan,
          decoration: const InputDecoration(labelText: 'Penyimpanan'),
          items: daftarPenyimpanan.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (nilai) => onPenyimpananBerubah(nilai!),
        ),
        jarak,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                validator: _wajibAngka,
              ),
            ),
            const SizedBox(width: AppTheme.jarakKecil),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: satuan,
                decoration: const InputDecoration(labelText: 'Satuan'),
                items: daftarSatuan.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (nilai) => onSatuanBerubah(nilai!),
              ),
            ),
          ],
        ),
        jarak,
        TextFormField(
          controller: hargaNormalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Harga normal (Rp)'),
          validator: _wajibAngka,
        ),
        jarak,
        TextFormField(
          controller: hargaMinimumController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Harga minimum (Rp)',
            helperText: 'Batas terendah lelang, tidak boleh melebihi harga normal',
          ),
          validator: (nilai) {
            final String? galat = _wajibAngka(nilai);
            if (galat != null) return galat;
            final double normal = double.tryParse(hargaNormalController.text) ?? 0;
            return double.parse(nilai!) > normal ? 'Melebihi harga normal' : null;
          },
        ),
        jarak,
        TextFormField(
          controller: nomorBatchController,
          decoration: const InputDecoration(labelText: 'Nomor batch'),
          validator: (nilai) => _wajibIsi(nilai, 'Nomor batch'),
        ),
        jarak,
        TextFormField(
          controller: tanggalController,
          readOnly: true,
          onTap: onPilihTanggal,
          decoration: const InputDecoration(
            labelText: 'Tanggal kedaluwarsa',
            helperText: 'Minimal 30 hari dari hari ini',
            suffixIcon: Icon(Icons.calendar_today_outlined),
          ),
          validator: (nilai) => _wajibIsi(nilai, 'Tanggal kedaluwarsa'),
        ),
      ],
    );
  }
}
