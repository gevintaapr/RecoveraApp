import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/draft_listing_model.dart';
import '../../models/invoice_result_model.dart';
import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar_upload.dart';
import '../../widgets/bar_bawah_kaca.dart';
import '../../widgets/chip_lembut.dart';
import '../../widgets/kartu_bagian.dart';
import '../../widgets/pilih_foto.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';
import 'listing_form_screen.dart';

// Upload stok langkah 1 (penjual): foto faktur -> OCR.
// - Pilih foto faktur (kamera/galeri) -> setState menyimpan fotonya.
// - "Pindai faktur" -> ApiService.unggahFaktur -> setState menampilkan
//   daftar barang hasil OCR. Ketuk barang -> form listing terisi otomatis.
// - OCR gagal / tanpa faktur -> "Isi manual" membuka form kosong.
// - Bagian bawah: draft yang tersimpan di HP (Hive, ValueListenableBuilder).
class UploadInvoiceScreen extends StatefulWidget {
  const UploadInvoiceScreen({super.key});

  @override
  State<UploadInvoiceScreen> createState() => _UploadInvoiceScreenState();
}

class _UploadInvoiceScreenState extends State<UploadInvoiceScreen> {
  Uint8List? _fotoFaktur;
  String _namaFileFaktur = 'faktur.jpg';
  bool _sedangMemindai = false;
  InvoiceResultModel? _hasilOcr;

  void _simpanFoto(Uint8List isiFile, String namaFile) {
    setState(() {
      _fotoFaktur = isiFile;
      _namaFileFaktur = namaFile;
      _hasilOcr = null; // foto baru -> hasil lama tidak berlaku
    });
  }

  Future<void> _pindaiFaktur() async {
    if (_fotoFaktur == null) return;
    setState(() => _sedangMemindai = true);
    try {
      final InvoiceResultModel hasil = await ApiService.unggahFaktur(
        isiFile: _fotoFaktur!,
        namaFile: _namaFileFaktur,
      );
      if (!mounted) return;
      setState(() => _hasilOcr = hasil);
    } catch (e) {
      if (!mounted) return;
      final String pesan = e.toString().replaceFirst('Exception: ', '');
      if (pesan == 'Sesi berakhir') {
        await kembaliKeLogin(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$pesan. Silakan isi form secara manual.')),
      );
    } finally {
      if (mounted) setState(() => _sedangMemindai = false);
    }
  }

  // Data dikirim ke form lewat parameter konstruktor (Modul IV).
  void _bukaForm({InvoiceItemModel? itemFaktur, DraftListingModel? draft}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingFormScreen(itemFaktur: itemFaktur, draft: draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarUpload(langkahAktif: 1),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.jarakTepi),
        children: [
          const Text(
            'Foto faktur pembelian. Data barang dibaca otomatis (OCR) untuk mengisi form.',
            style: AppTheme.gayaTeksRedup,
          ),
          const SizedBox(height: AppTheme.jarakKecil),
          PilihFoto(gambar: _fotoFaktur, teksKosong: 'Belum ada foto faktur', onFotoDipilih: _simpanFoto),
          if (_hasilOcr != null) ...[
            const SizedBox(height: AppTheme.jarakKecil),
            _HasilOcr(hasil: _hasilOcr!, onItemDipilih: (item) => _bukaForm(itemFaktur: item)),
          ],
          const SizedBox(height: AppTheme.jarakKecil),
          // ValueListenableBuilder (Modul VI): daftar ikut berubah sendiri
          // setiap draft disimpan atau dihapus di box Hive 'draft_listings'.
          ValueListenableBuilder(
            valueListenable: LocalDbService.pantauDraft(),
            builder: (context, box, child) {
              final List<DraftListingModel> daftarDraft = LocalDbService.ambilSemuaDraft();
              return KartuBagian(
                judul: 'Draft tersimpan di HP',
                children: daftarDraft.isEmpty
                    ? const [Text('Belum ada draft.', style: AppTheme.gayaTeksRedup)]
                    : daftarDraft
                        .map((draft) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.edit_note, color: AppTheme.warnaTeksSedang),
                              title: Text(draft.namaProduk,
                                  style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w700)),
                              subtitle: Text(
                                '${draft.jumlah} ${draft.satuan} · '
                                'disimpan ${ListingModel.formatTanggal(draft.waktuDisimpan)}',
                                style: const TextStyle(fontSize: AppTheme.fontLabel),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Hapus draft',
                                onPressed: () => LocalDbService.hapusDraft(draft.idDraft),
                              ),
                              onTap: () => _bukaForm(draft: draft),
                            ))
                        .toList(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BarBawahKaca(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppTheme.tinggiTombol)),
                onPressed: () => _bukaForm(),
                child: const Text('Isi manual'),
              ),
            ),
            const SizedBox(width: AppTheme.jarakKecil),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                teks: 'Pindai faktur',
                ikon: Icons.document_scanner_outlined,
                sedangMemuat: _sedangMemindai,
                onPressed: _fotoFaktur == null ? null : _pindaiFaktur,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Daftar barang hasil OCR. Ketuk satu barang untuk membuka form terisi.
class _HasilOcr extends StatelessWidget {
  final InvoiceResultModel hasil;
  final ValueChanged<InvoiceItemModel> onItemDipilih;

  const _HasilOcr({required this.hasil, required this.onItemDipilih});

  @override
  Widget build(BuildContext context) {
    if (hasil.ditolak || hasil.daftarItem.isEmpty) {
      return KartuBagian(
        judul: 'Faktur tidak terbaca',
        children: [
          Text(
            hasil.alasanDitolak ?? 'Coba foto ulang, atau isi form secara manual.',
            style: AppTheme.gayaTeksRedup,
          ),
        ],
      );
    }

    return KartuBagian(
      judul: 'Hasil baca faktur${hasil.namaPemasok == null ? '' : ' · ${hasil.namaPemasok}'}',
      kanan: const ChipLembut(teks: 'OCR', warnaLatar: AppTheme.warnaLatarInfo, warnaTeks: AppTheme.warnaTeksInfo),
      children: [
        if (hasil.pakaiDataContoh)
          const ChipLembut(
            teks: 'OCR tidak tersedia, server menampilkan data contoh',
            warnaLatar: AppTheme.warnaLatarPeringatan,
            warnaTeks: AppTheme.warnaTeksPeringatan,
          ),
        const Text('Ketuk barang untuk melanjutkan.', style: AppTheme.gayaTeksRedup),
        ...hasil.daftarItem.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.inventory_2_outlined, color: AppTheme.warnaUtama),
              title: Text(item.namaProduk,
                  style: const TextStyle(fontSize: AppTheme.fontNormal, fontWeight: FontWeight.w700)),
              subtitle: Text(
                '${item.jumlah} ${item.satuan} · ${ListingModel.formatRupiah(item.hargaNormal)}'
                '${item.tanggalKedaluwarsa == null ? '' : ' · exp ${ListingModel.formatTanggal(item.tanggalKedaluwarsa!)}'}',
                style: const TextStyle(fontSize: AppTheme.fontLabel),
              ),
              // Keyakinan rendah ditandai amber supaya penjual mengecek ulang.
              trailing: ChipLembut(
                teks: '${item.persenKeyakinan}% yakin',
                warnaLatar: item.persenKeyakinan < 70 ? AppTheme.warnaLatarPeringatan : AppTheme.warnaLatarNetral,
                warnaTeks: item.persenKeyakinan < 70 ? AppTheme.warnaTeksPeringatan : AppTheme.warnaTeksSedang,
              ),
              onTap: () => onItemDipilih(item),
            )),
      ],
    );
  }
}
