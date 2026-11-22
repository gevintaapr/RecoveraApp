import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Kotak satu angka ringkasan di Dasbor penjual (mis. "Lelang aktif 12").
// Angka harus berasal dari data server; widget ini hanya menampilkan.
// keterangan opsional untuk konteks di bawah angka (mis. "tertua 2 jam lalu").
class KartuAngka extends StatelessWidget {
  final String label;
  final String nilai;
  final Color warnaNilai;
  final String? keterangan;
  final VoidCallback? onTap;

  const KartuAngka({
    super.key,
    required this.label,
    required this.nilai,
    this.warnaNilai = AppTheme.warnaNavy,
    this.keterangan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.jarakSedang),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
              ),
              const SizedBox(height: AppTheme.jarakMini / 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  nilai,
                  style: TextStyle(
                    fontSize: AppTheme.fontBesar,
                    fontWeight: FontWeight.w800,
                    color: warnaNilai,
                  ),
                ),
              ),
              if (keterangan != null)
                Text(
                  keterangan!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: AppTheme.fontLabel, color: AppTheme.warnaTeksRedup),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
