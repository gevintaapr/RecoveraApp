import 'package:flutter/material.dart';

import '../services/session_service.dart';
import '../theme/app_theme.dart';

// Dialog verifikasi PIN transaksi 6 digit (Modul II Widget & Modul III State).
// Dipanggil sebelum memproses Beli Sekarang untuk otorisasi keamanan B2B.
Future<bool?> tampilkanDialogPinTransaksi(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _DialogPinTransaksi(),
  );
}

class _DialogPinTransaksi extends StatefulWidget {
  const _DialogPinTransaksi();

  @override
  State<_DialogPinTransaksi> createState() => _DialogPinTransaksiState();
}

class _DialogPinTransaksiState extends State<_DialogPinTransaksi> {
  String _pin = '';
  String? _pesanError;
  bool _sedangMemverifikasi = false;

  void _tekanAngka(String angka) {
    if (_sedangMemverifikasi || _pin.length >= 6) return;
    setState(() {
      _pesanError = null;
      _pin += angka;
    });

    if (_pin.length == 6) {
      _verifikasi();
    }
  }

  void _hapusAngka() {
    if (_sedangMemverifikasi || _pin.isEmpty) return;
    setState(() {
      _pesanError = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verifikasi() async {
    setState(() => _sedangMemverifikasi = true);
    // Verifikasi ke SharedPreferences (Modul VI)
    final bool cocok = await SessionService.verifikasiPin(_pin);
    if (!mounted) return;

    if (cocok) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _pin = '';
        _pesanError = 'PIN salah. Silakan coba lagi.';
        _sedangMemverifikasi = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius * 1.5),
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        AppTheme.jarakSedang,
        AppTheme.jarakBesar,
        AppTheme.jarakSedang,
        AppTheme.jarakSedang,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.jarakSedang),
            decoration: BoxDecoration(
              color: AppTheme.warnaUtama.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 36,
              color: AppTheme.warnaUtama,
            ),
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          const Text(
            'PIN Transaksi',
            style: TextStyle(
              fontSize: AppTheme.fontSubjudul,
              fontWeight: FontWeight.bold,
              color: AppTheme.warnaTeks,
            ),
          ),
          const SizedBox(height: AppTheme.jarakKecil / 2),
          const Text(
            'Masukkan 6 digit PIN keamanan transaksi Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontKecil,
              color: AppTheme.warnaTeksRedup,
            ),
          ),
          const SizedBox(height: AppTheme.jarakBesar),

          // 6 Titik PIN Indikator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              final bool terisi = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: terisi ? AppTheme.warnaUtama : Colors.transparent,
                  border: Border.all(
                    color: terisi ? AppTheme.warnaUtama : AppTheme.warnaGaris,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppTheme.jarakSedang),

          // Pesan Error bila PIN salah
          if (_pesanError != null) ...[
            Text(
              _pesanError!,
              style: const TextStyle(
                fontSize: AppTheme.fontKecil,
                color: AppTheme.warnaGalat,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.jarakKecil),
          ],

          // Keypad Angka 3x4
          SizedBox(
            width: 240,
            child: Column(
              children: [
                _barisKeypad(['1', '2', '3']),
                const SizedBox(height: AppTheme.jarakKecil),
                _barisKeypad(['4', '5', '6']),
                const SizedBox(height: AppTheme.jarakKecil),
                _barisKeypad(['7', '8', '9']),
                const SizedBox(height: AppTheme.jarakKecil),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol Batal
                    _tombolAksi(
                      icon: Icons.close,
                      onTap: () => Navigator.pop(context, false),
                    ),
                    // Angka 0
                    _tombolAngka('0'),
                    // Tombol Backspace
                    _tombolAksi(
                      icon: Icons.backspace_outlined,
                      onTap: _hapusAngka,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barisKeypad(List<String> angka) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: angka.map((a) => _tombolAngka(a)).toList(),
    );
  }

  Widget _tombolAngka(String angka) {
    return InkWell(
      onTap: () => _tekanAngka(angka),
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Container(
        width: 60,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.warnaLatar,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppTheme.warnaGaris),
        ),
        child: Text(
          angka,
          style: const TextStyle(
            fontSize: AppTheme.fontSubjudul,
            fontWeight: FontWeight.w600,
            color: AppTheme.warnaTeks,
          ),
        ),
      ),
    );
  }

  Widget _tombolAksi({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius),
      child: Container(
        width: 60,
        height: 48,
        alignment: Alignment.center,
        child: Icon(icon, color: AppTheme.warnaTeksRedup, size: 22),
      ),
    );
  }
}
