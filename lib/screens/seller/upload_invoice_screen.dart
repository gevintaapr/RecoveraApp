import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/draft_listing_model.dart';
import '../../models/invoice_result_model.dart';
import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pilih_foto.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';
import 'listing_form_screen.dart';

// Upload stok langkah 1 (penjual): foto faktur -> OCR.
// - Pilih foto faktur (kamera/galeri) -> setState menyimpan fotonya.
// - "Pindai Faktur" -> ApiService.unggahFaktur -> setState menampilkan
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
      appBar: AppBar(title: const Text('Upload Stok')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        children: [
          const Text('Langkah 1: Foto faktur', style: AppTheme.gayaSubjudul),
          const SizedBox(height: AppTheme.jarakKecil / 2),
          const Text(
            'Foto faktur pembelian. Data barang dibaca otomatis (OCR) untuk mengisi form.',
            style: AppTheme.gayaTeksRedup,
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          PilihFoto(
            gambar: _fotoFaktur,
            teksKosong: 'Belum ada foto faktur',
            onFotoDipilih: _simpanFoto,
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          PrimaryButton(
            teks: 'Pindai Faktur',
            sedangMemuat: _sedangMemindai,
            onPressed: _fotoFaktur == null ? null : _pindaiFaktur,
          ),
          TextButton(
            onPressed: () => _bukaForm(),
            child: const Text('Isi manual tanpa faktur'),
          ),
          if (_hasilOcr != null) _HasilOcr(hasil: _hasilOcr!, onItemDipilih: (item) => _bukaForm(itemFaktur: item)),
          const Divider(height: AppTheme.jarakBesar * 2),
          const Text('Draft tersimpan di HP', style: AppTheme.gayaSubjudul),
          const SizedBox(height: AppTheme.jarakKecil),
          // ValueListenableBuilder (Modul VI): daftar ikut berubah sendiri
          // setiap draft disimpan atau dihapus di box Hive 'draft_listings'.
          ValueListenableBuilder(
            valueListenable: LocalDbService.pantauDraft(),
            builder: (context, box, child) {
              final List<DraftListingModel> daftarDraft = LocalDbService.ambilSemuaDraft();
              if (daftarDraft.isEmpty) {
                return const Text('Belum ada draft.', style: AppTheme.gayaTeksRedup);
              }
              return Column(
                children: daftarDraft
                    .map((draft) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.edit_note),
                            title: Text(draft.namaProduk),
                            subtitle: Text('${draft.jumlah} ${draft.satuan} · '
                                'disimpan ${ListingModel.formatTanggal(draft.waktuDisimpan)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Hapus draft',
                              onPressed: () => LocalDbService.hapusDraft(draft.idDraft),
                            ),
                            onTap: () => _bukaForm(draft: draft),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
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
      return Card(
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: AppTheme.warnaGalat),
          title: const Text('Faktur tidak terbaca'),
          subtitle: Text(hasil.alasanDitolak ?? 'Coba foto ulang, atau isi form secara manual.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppTheme.jarakKecil),
        Text('Hasil pindai${hasil.namaPemasok == null ? '' : ' · ${hasil.namaPemasok}'}',
            style: AppTheme.gayaSubjudul),
        if (hasil.pakaiDataContoh)
          const Text('OCR tidak tersedia, server menampilkan data contoh.',
              style: TextStyle(color: AppTheme.warnaAksen)),
        const Text('Ketuk barang untuk melanjutkan.', style: AppTheme.gayaTeksRedup),
        const SizedBox(height: AppTheme.jarakKecil),
        ...hasil.daftarItem.map((item) => Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined, color: AppTheme.warnaUtama),
                title: Text(item.namaProduk),
                subtitle: Text('${item.jumlah} ${item.satuan} · '
                    '${ListingModel.formatRupiah(item.hargaNormal)}'
                    '${item.tanggalKedaluwarsa == null ? '' : ' · exp ${ListingModel.formatTanggal(item.tanggalKedaluwarsa!)}'}'),
                trailing: Text('${item.persenKeyakinan}%', style: AppTheme.gayaTeksRedup),
                onTap: () => onItemDipilih(item),
              ),
            )),
      ],
    );
  }
}
