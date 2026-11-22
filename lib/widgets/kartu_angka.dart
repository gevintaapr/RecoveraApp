import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Kotak satu angka ringkasan di Dasbor penjual (_BentoCard Recovera lama):
// ikon dalam kotak berwarna lembut, label, angka besar, keterangan kecil.
// Angka harus berasal dari data server; widget ini hanya menampilkan.
class KartuAngka extends StatelessWidget {
  final String label;
  final String nilai;
  final IconData ikon;
  final Color warna;
  final String? keterangan;
  final VoidCallback? onTap;

  const KartuAngka({
    super.key,
    required this.label,
    required this.nilai,
    this.ikon = Icons.insights_outlined,
    this.warna = AppTheme.warnaUtama,
    this.keterangan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Container memberi warna putih + bayangan berwarna (bento lama); Material
    // transparan di dalamnya hanya untuk efek sentuh InkWell.
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.warnaPermukaan,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: [BoxShadow(color: warna.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.jarakTepi),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.jarakKecil),
                      decoration: BoxDecoration(
                        color: warna.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSedang),
                      ),
                      child: Icon(ikon, color: warna, size: AppTheme.ikonSedang),
                    ),
                    const SizedBox(width: AppTheme.jarakKecil),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppTheme.fontInput,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warnaTeksRedup,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              nilai,
                              style: const TextStyle(
                                fontSize: AppTheme.fontAngkaBento,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.warnaNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (keterangan != null) ...[
                  const SizedBox(height: AppTheme.jarakLabel),
                  Text(
                    keterangan!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: AppTheme.fontKecil, fontWeight: FontWeight.w500, color: AppTheme.warnaTeksRedup),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
