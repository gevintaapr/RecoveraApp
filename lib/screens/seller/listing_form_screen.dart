import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/draft_listing_model.dart';
import '../../models/invoice_result_model.dart';
import '../../models/listing_model.dart';
import '../../models/price_advice_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/form_data_produk.dart';
import '../../widgets/kartu_rekomendasi_harga.dart';
import '../../widgets/pilih_foto.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';

// Upload stok langkah 2 (penjual): data produk -> rekomendasi harga -> terbitkan.
// Form diisi otomatis dari hasil OCR (itemFaktur) atau dari draft Hive (draft);
// keduanya dikirim lewat konstruktor dari UploadInvoiceScreen.
// - "Simpan Draft"  -> LocalDbService.simpanDraft (Hive, tanpa internet).
// - "Lanjut"        -> unggahGambarProduk -> buatDraft -> ambilRekomendasiHarga,
//                      lalu setState menampilkan kartu rekomendasi.
// - "Terbitkan"     -> terbitkanListing -> notifikasi "Listing terbit".
class ListingFormScreen extends StatefulWidget {
  final InvoiceItemModel? itemFaktur;
  final DraftListingModel? draft;

  const ListingFormScreen({super.key, this.itemFaktur, this.draft});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final GlobalKey<FormState> _kunciForm = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController merekController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController hargaNormalController = TextEditingController();
  final TextEditingController hargaMinimumController = TextEditingController();
  final TextEditingController nomorBatchController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  String _kategori = 'General';
  String _penyimpanan = 'ambient';
  String _satuan = 'pcs';
  DateTime? _tanggalKedaluwarsa;
  Uint8List? _fotoProduk;
  String _namaFileFoto = 'produk.jpg';
  String? _galatFoto;

  bool _sedangMemproses = false;
  ListingModel? _draftServer; // terisi setelah "Lanjut" berhasil
  PriceAdviceModel? _saranHarga;

  // Masa simpan minimal 30 hari (aturan backend agar lelang sempat berjalan).
  DateTime get _tanggalPalingAwal => DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    nomorBatchController.text = 'LOT-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final InvoiceItemModel? item = widget.itemFaktur;
    final DraftListingModel? draft = widget.draft;
    if (item != null) {
      namaController.text = item.namaProduk;
      merekController.text = item.merek ?? '';
      jumlahController.text = '${item.jumlah}';
      hargaNormalController.text = item.hargaNormal.round().toString();
      hargaMinimumController.text = (item.hargaNormal * 0.3).round().toString();
      if (FormDataProduk.daftarKategori.contains(item.kategori)) _kategori = item.kategori;
      if (FormDataProduk.daftarSatuan.contains(item.satuan)) _satuan = item.satuan;
      _aturTanggal(item.tanggalKedaluwarsa);
    } else if (draft != null) {
      namaController.text = draft.namaProduk;
      merekController.text = draft.merek ?? '';
      jumlahController.text = draft.jumlah > 0 ? '${draft.jumlah}' : '';
      hargaNormalController.text = draft.hargaNormal > 0 ? draft.hargaNormal.round().toString() : '';
      hargaMinimumController.text = draft.hargaMinimum > 0 ? draft.hargaMinimum.round().toString() : '';
      nomorBatchController.text = draft.nomorBatch;
      _kategori = draft.kategori;
      _penyimpanan = draft.jenisPenyimpanan;
      _satuan = draft.satuan;
      _fotoProduk = draft.gambarProduk;
      _aturTanggal(draft.tanggalKedaluwarsa);
    }
  }

  // Tanggal dari OCR/draft hanya dipakai bila masih memenuhi batas 30 hari.
  void _aturTanggal(DateTime? tanggal) {
    if (tanggal == null || tanggal.isBefore(_tanggalPalingAwal)) return;
    _tanggalKedaluwarsa = tanggal;
    tanggalController.text = ListingModel.formatTanggal(tanggal);
  }

  @override
  void dispose() {
    namaController.dispose();
    merekController.dispose();
    jumlahController.dispose();
    hargaNormalController.dispose();
    hargaMinimumController.dispose();
    nomorBatchController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalKedaluwarsa ?? _tanggalPalingAwal,
      firstDate: _tanggalPalingAwal,
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (hasil == null || !mounted) return;
    setState(() => _aturTanggal(hasil));
  }

  // Draft lokal: cukup nama produk; kolom lain boleh kosong dulu.
  Future<void> _simpanDraftLokal() async {
    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama produk dulu untuk menyimpan draft')),
      );
      return;
    }
    await LocalDbService.simpanDraft(DraftListingModel(
      idDraft: widget.draft?.idDraft ?? '${DateTime.now().millisecondsSinceEpoch}',
      namaProduk: namaController.text.trim(),
      merek: merekController.text.trim(),
      kategori: _kategori,
      jenisPenyimpanan: _penyimpanan,
      satuan: _satuan,
      jumlah: int.tryParse(jumlahController.text) ?? 0,
      hargaNormal: double.tryParse(hargaNormalController.text) ?? 0,
      hargaMinimum: double.tryParse(hargaMinimumController.text) ?? 0,
      tanggalKedaluwarsa: _tanggalKedaluwarsa ?? _tanggalPalingAwal,
      nomorBatch: nomorBatchController.text.trim(),
      gambarProduk: _fotoProduk,
      waktuDisimpan: DateTime.now(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft disimpan di HP')),
    );
    Navigator.pop(context);
  }

  // Lanjut: foto -> draft di server -> rekomendasi harga.
  Future<void> _lanjutKeRekomendasi() async {
    final bool formValid = _kunciForm.currentState!.validate();
    setState(() => _galatFoto = _fotoProduk == null ? 'Foto produk wajib diunggah' : null);
    if (!formValid || _fotoProduk == null) return;

    setState(() => _sedangMemproses = true);
    try {
      final String urlGambar = await ApiService.unggahGambarProduk(
        isiFile: _fotoProduk!,
        namaFile: _namaFileFoto,
      );
      final ListingModel draftServer = await ApiService.buatDraft(
        namaProduk: namaController.text.trim(),
        merek: merekController.text.trim(),
        kategori: _kategori,
        jenisPenyimpanan: _penyimpanan,
        satuan: _satuan,
        urlGambar: urlGambar,
        nomorBatch: nomorBatchController.text.trim(),
        jumlah: int.parse(jumlahController.text),
        hargaNormal: double.parse(hargaNormalController.text),
        hargaMinimum: double.parse(hargaMinimumController.text),
        tanggalKedaluwarsa: _tanggalKedaluwarsa!,
      );
      final PriceAdviceModel saran = await ApiService.ambilRekomendasiHarga(draftServer.id);
      // Draft sudah tersimpan di server, salinan di HP tidak diperlukan lagi.
      if (widget.draft != null) await LocalDbService.hapusDraft(widget.draft!.idDraft);
      if (!mounted) return;
      setState(() {
        _draftServer = draftServer;
        _saranHarga = saran;
      });
    } catch (e) {
      await _tampilkanGalat(e);
    } finally {
      if (mounted) setState(() => _sedangMemproses = false);
    }
  }

  Future<void> _terbitkan() async {
    try {
      final bool berhasil = await terbitkanDenganKonfirmasi(
        context,
        idListing: _draftServer!.id,
        saran: _saranHarga!,
      );
      if (!berhasil || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing berhasil diterbitkan')),
      );
      // Kembali ke MainShell (melewati layar upload faktur).
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      await _tampilkanGalat(e);
    }
  }

  Future<void> _tampilkanGalat(Object e) async {
    if (!mounted) return;
    final String pesan = e.toString().replaceFirst('Exception: ', '');
    if (pesan == 'Sesi berakhir') {
      await kembaliKeLogin(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_draftServer == null ? 'Data Produk' : 'Rekomendasi Harga')),
      body: _draftServer == null ? _buatForm() : _buatTahapTerbit(),
    );
  }

  // Tahap setelah "Lanjut": kartu rekomendasi + tombol Terbitkan.
  Widget _buatTahapTerbit() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.jarakSedang),
      children: [
        KartuRekomendasiHarga(saran: _saranHarga!, draft: _draftServer!),
        const SizedBox(height: AppTheme.jarakBesar),
        PrimaryButton(teks: 'Terbitkan', onPressed: _terbitkan),
        const SizedBox(height: AppTheme.jarakKecil),
        const Text(
          'Belum ingin terbit? Draft ini tetap tersimpan di server dan bisa diterbitkan dari halaman Stok.',
          style: AppTheme.gayaTeksRedup,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buatForm() {
    return Form(
      key: _kunciForm,
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.jarakSedang),
        children: [
          PilihFoto(
            gambar: _fotoProduk,
            teksKosong: 'Foto produk (wajib)',
            pesanGalat: _galatFoto,
            onFotoDipilih: (isiFile, namaFile) => setState(() {
              _fotoProduk = isiFile;
              _namaFileFoto = namaFile;
              _galatFoto = null;
            }),
          ),
          const SizedBox(height: AppTheme.jarakSedang),
          FormDataProduk(
            namaController: namaController,
            merekController: merekController,
            jumlahController: jumlahController,
            hargaNormalController: hargaNormalController,
            hargaMinimumController: hargaMinimumController,
            nomorBatchController: nomorBatchController,
            tanggalController: tanggalController,
            kategori: _kategori,
            penyimpanan: _penyimpanan,
            satuan: _satuan,
            onKategoriBerubah: (nilai) => setState(() => _kategori = nilai),
            onPenyimpananBerubah: (nilai) => setState(() => _penyimpanan = nilai),
            onSatuanBerubah: (nilai) => setState(() => _satuan = nilai),
            onPilihTanggal: _pilihTanggal,
          ),
          const SizedBox(height: AppTheme.jarakBesar),
          PrimaryButton(
            teks: 'Lanjut: Rekomendasi Harga',
            sedangMemuat: _sedangMemproses,
            onPressed: _lanjutKeRekomendasi,
          ),
          const SizedBox(height: AppTheme.jarakKecil),
          OutlinedButton(
            onPressed: _sedangMemproses ? null : _simpanDraftLokal,
            child: const Text('Simpan Draft di HP'),
          ),
        ],
      ),
    );
  }
}
