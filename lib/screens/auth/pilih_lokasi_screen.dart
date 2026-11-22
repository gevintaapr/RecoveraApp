import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// CATATAN: Menggunakan flutter_map + latlong2 (elemen di luar modul)
// Fungsi: menampilkan peta OpenStreetMap dan menaruh pin di titik yang diketuk.
// Alasan: pemilik proyek meminta pilih lokasi dari peta seperti Recovera lama;
//         Modul VII hanya mengajarkan geolocator (koordinat GPS), tanpa peta.
// Cara kerja: FlutterMap memuat ubin peta dari tile.openstreetmap.org; onTap
//         memberi koordinat (LatLng) titik yang diketuk; MarkerLayer menggambar pin.
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/primary_button.dart';

// Layar pilih lokasi gudang / usaha dari peta (dipanggil dari Register).
// - Ketuk peta -> setState memindah pin -> nama kota dicari (LocationService.ambilNamaKota).
// - "Lokasi saya" -> GPS (geolocator, Modul VII) -> peta & pin pindah ke posisi HP.
// - "Simpan lokasi ini" -> Navigator.pop membawa TitikLokasi ke Register.
class PilihLokasiScreen extends StatefulWidget {
  final String judul;
  final TitikLokasi? awal;

  const PilihLokasiScreen({super.key, required this.judul, this.awal});

  @override
  State<PilihLokasiScreen> createState() => _PilihLokasiScreenState();
}

class _PilihLokasiScreenState extends State<PilihLokasiScreen> {
  // Titik awal bila belum ada lokasi: Monas, Jakarta.
  static const LatLng _titikBawaan = LatLng(-6.1754, 106.8272);

  final MapController _petaController = MapController();
  late LatLng _titik;
  String? _namaKota;
  bool _sedangMencariKota = false;

  @override
  void initState() {
    super.initState();
    final TitikLokasi? awal = widget.awal;
    _titik = awal == null ? _titikBawaan : LatLng(awal.lat, awal.lng);
    _namaKota = awal?.kota;
    if (awal == null) _cariNamaKota();
  }

  @override
  void dispose() {
    _petaController.dispose();
    super.dispose();
  }

  Future<void> _cariNamaKota() async {
    setState(() => _sedangMencariKota = true);
    final String kota = await LocationService.ambilNamaKota(_titik.latitude, _titik.longitude);
    if (!mounted) return;
    setState(() {
      _namaKota = kota;
      _sedangMencariKota = false;
    });
  }

  void _pindahkanPin(LatLng titikBaru) {
    setState(() {
      _titik = titikBaru;
      _namaKota = null;
    });
    _cariNamaKota();
  }

  // Tombol "Lokasi saya": dialog loading -> GPS -> peta bergeser ke posisi HP.
  Future<void> _keLokasiSaya() async {
    tampilkanDialogMemuat(context, pesan: 'Mengambil lokasi HP...');
    try {
      final Position posisi = await LocationService.ambilLokasiSaatIni();
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog loading
      final LatLng titikHp = LatLng(posisi.latitude, posisi.longitude);
      _petaController.move(titikHp, 16);
      _pindahkanPin(titikHp);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: AppTheme.warnaGalat),
      );
    }
  }

  void _simpan() {
    Navigator.pop(
      context,
      TitikLokasi(lat: _titik.latitude, lng: _titik.longitude, kota: _namaKota!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String teksLokasi = _namaKota == null
        ? 'Mendeteksi kota...'
        : LocationService.formatLokasi(_namaKota!, _titik.latitude, _titik.longitude);

    return Scaffold(
      appBar: AppBar(title: Text(widget.judul)),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.jarakTepi),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ketuk peta untuk memindahkan pin ke lokasi yang benar.', style: AppTheme.gayaTeksRedup),
            const SizedBox(height: AppTheme.jarakKecil),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.warnaLatarPeta,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: AppTheme.warnaGarisCari, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusPeta),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _petaController,
                        options: MapOptions(
                          initialCenter: _titik,
                          initialZoom: 15,
                          minZoom: 3,
                          maxZoom: 18,
                          onTap: (posisiKetuk, titik) => _pindahkanPin(titik),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.recoveraa',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _titik,
                                width: AppTheme.kotakPin,
                                height: AppTheme.kotakPin,
                                alignment: Alignment.topCenter,
                                child: const Icon(Icons.location_on_rounded, size: AppTheme.ikonPin, color: AppTheme.warnaPinPeta),
                              ),
                            ],
                          ),
                          // Atribusi wajib menurut aturan pemakaian ubin OpenStreetMap.
                          const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
                        ],
                      ),
                      Positioned(
                        top: AppTheme.radiusSedang,
                        left: AppTheme.radiusSedang,
                        child: _LabelKoordinat(titik: _titik),
                      ),
                      Positioned(
                        right: AppTheme.jarakSedang,
                        bottom: AppTheme.jarakAtasTombolPeta,
                        child: FloatingActionButton.small(
                          heroTag: 'lokasi_saya',
                          tooltip: 'Lokasi saya',
                          backgroundColor: AppTheme.warnaPermukaan,
                          foregroundColor: AppTheme.warnaUtama,
                          onPressed: _keLokasiSaya,
                          child: const Icon(Icons.my_location_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.jarakSedang),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppTheme.warnaUtama, size: AppTheme.ikonMata),
                const SizedBox(width: AppTheme.jarakKecil),
                Expanded(
                  child: Text(
                    teksLokasi,
                    style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w600, color: AppTheme.warnaNavy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.jarakSedang),
            SafeArea(
              top: false,
              child: PrimaryButton(
                teks: 'Simpan lokasi ini',
                ikon: Icons.check_rounded,
                // Tunggu nama kota selesai dicari supaya format "Kota (lat, lng)" lengkap.
                onPressed: (_sedangMencariKota || _namaKota == null) ? null : _simpan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Label koordinat langsung di pojok kiri atas peta.
class _LabelKoordinat extends StatelessWidget {
  final LatLng titik;

  const _LabelKoordinat({required this.titik});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.radiusSedang, vertical: AppTheme.jarakMini),
      decoration: BoxDecoration(
        color: AppTheme.warnaPanelPeta,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
        border: Border.all(color: AppTheme.warnaGaris),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.explore_rounded, size: AppTheme.ikonCentang, color: AppTheme.warnaUtama),
          const SizedBox(width: AppTheme.jarakLabel),
          Text(
            'Lat: ${titik.latitude.toStringAsFixed(4)}, Lng: ${titik.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: AppTheme.fontLabel, fontWeight: FontWeight.w600, color: AppTheme.warnaNavy),
          ),
        ],
      ),
    );
  }
}
