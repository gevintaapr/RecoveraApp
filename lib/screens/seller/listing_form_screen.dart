import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/draft_listing_model.dart';
import '../../models/listing_model.dart';
import '../../models/price_advice_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar_upload.dart';
import '../../widgets/bar_bawah_form_listing.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/dialog_ubah_harga_awal.dart';
import '../../widgets/form_data_produk.dart';
import '../../widgets/isi_tahap_terbit.dart';
import '../../widgets/kartu_rekomendasi_harga.dart';
import '../../widgets/pilih_foto.dart';
import '../auth/login_screen.dart';

// Upload stok (penjual):
// Langkah 1: Data Produk (form manual / draf lokal)
// Langkah 2: Review Data, Rekomendasi Harga, & Terbitkan (T7)
class ListingFormScreen extends StatefulWidget {
  final DraftListingModel? draft;

  const ListingFormScreen({super.key, this.draft});

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
  ListingModel? _draftServer;
  PriceAdviceModel? _saranHarga;

  DateTime get _tanggalPalingAwal =>
      DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    nomorBatchController.text =
        'LOT-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final DraftListingModel? draft = widget.draft;
    if (draft != null) {
      namaController.text = draft.namaProduk;
      merekController.text = draft.merek ?? '';
      jumlahController.text = draft.jumlah > 0 ? '${draft.jumlah}' : '';
      hargaNormalController.text =
          draft.hargaNormal > 0 ? draft.hargaNormal.round().toString() : '';
      hargaMinimumController.text =
          draft.hargaMinimum > 0 ? draft.hargaMinimum.round().toString() : '';
      nomorBatchController.text = draft.nomorBatch;
      _kategori = draft.kategori;
      _penyimpanan = draft.jenisPenyimpanan;
      _satuan = draft.satuan;
      _fotoProduk = draft.gambarProduk;
      _aturTanggal(draft.tanggalKedaluwarsa);
    }
  }

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

  Future<void> _simpanDraftLokal() async {
    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi nama produk dulu untuk menyimpan draft'),
        ),
      );
      return;
    }
    await LocalDbService.simpanDraft(DraftListingModel(
      idDraft:
          widget.draft?.idDraft ?? '${DateTime.now().millisecondsSinceEpoch}',
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

  Future<void> _lanjutKeRekomendasi() async {
    final bool formValid = _kunciForm.currentState!.validate();
    setState(() =>
        _galatFoto = _fotoProduk == null ? 'Foto produk wajib diunggah' : null);
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
      final PriceAdviceModel saran =
          await ApiService.ambilRekomendasiHarga(draftServer.id);
      if (widget.draft != null) {
        await LocalDbService.hapusDraft(widget.draft!.idDraft);
      }
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

  // Dialog Ubah Harga Awal Manual dengan Peringatan Rentang (T7)
  Future<void> _bukaDialogUbahHargaAwal() async {
    if (_draftServer == null || _saranHarga == null) return;

    final double hargaAwalSekarang =
        _draftServer!.hargaMulai ?? _saranHarga!.hargaSaran;
    final String? teksHarga = await tampilkanDialogUbahHargaAwal(
      context,
      hargaAwal: hargaAwalSekarang,
      batasBawah: _saranHarga!.batasBawah ?? (_saranHarga!.hargaSaran * 0.8),
      batasAtas: _saranHarga!.batasAtas ?? (_saranHarga!.hargaSaran * 1.2),
      hargaNormal: _draftServer!.hargaNormal,
      hargaMinimum: _draftServer!.hargaMinimum,
    );

    if (teksHarga == null || !mounted) return;

    final double? hargaBaru = double.tryParse(teksHarga);
    if (hargaBaru == null || hargaBaru <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan angka harga yang valid')),
      );
      return;
    }

    if (hargaBaru > _draftServer!.hargaNormal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harga awal tidak boleh melebihi harga normal (${ListingModel.formatRupiah(_draftServer!.hargaNormal)})',
          ),
          backgroundColor: AppTheme.warnaGalat,
        ),
      );
      return;
    }

    if (hargaBaru < _draftServer!.hargaMinimum) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harga awal tidak boleh kurang dari batas minimum (${ListingModel.formatRupiah(_draftServer!.hargaMinimum)})',
          ),
          backgroundColor: AppTheme.warnaGalat,
        ),
      );
      return;
    }

    tampilkanDialogMemuat(context, pesan: 'Menyimpan harga awal baru...');
    try {
      final ListingModel draftDiperbarui = await ApiService.ubahDraft(
        _draftServer!.id,
        {'start_price': hargaBaru},
      );
      final PriceAdviceModel saranBaru =
          await ApiService.ambilRekomendasiHarga(_draftServer!.id);
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog
      setState(() {
        _draftServer = draftDiperbarui;
        _saranHarga = saranBaru;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga awal lelang berhasil disesuaikan')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      await _tampilkanGalat(e);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: AppTheme.warnaGalat,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool tahapForm = _draftServer == null;
    return Scaffold(
      appBar: AppBarUpload(langkahAktif: tahapForm ? 1 : 2),
      body: tahapForm
          ? _buatForm()
          : IsiTahapTerbit(
              draftServer: _draftServer!,
              saranHarga: _saranHarga!,
              fotoLokal: _fotoProduk,
              onUbahHargaAwal: _bukaDialogUbahHargaAwal,
            ),
      bottomNavigationBar: BarBawahFormListing(
        tahapForm: tahapForm,
        sedangMemproses: _sedangMemproses,
        onTombolKiri: tahapForm ? _simpanDraftLokal : _bukaDialogUbahHargaAwal,
        onTombolKanan: tahapForm ? _lanjutKeRekomendasi : _terbitkan,
      ),
    );
  }

  Widget _buatForm() {
    return Form(
      key: _kunciForm,
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.jarakTepi),
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
            onPenyimpananBerubah: (nilai) =>
                setState(() => _penyimpanan = nilai),
            onSatuanBerubah: (nilai) => setState(() => _satuan = nilai),
            onPilihTanggal: _pilihTanggal,
          ),
        ],
      ),
    );
  }
}
