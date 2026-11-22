import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../models/draft_listing_model.dart';
import '../../models/invoice_result_model.dart';
import '../../models/listing_model.dart';
import '../../models/price_advice_model.dart';
import '../../services/api_service.dart';
import '../../services/local_db_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar_upload.dart';
import '../../widgets/bar_bawah_kaca.dart';
import '../../widgets/dialog_memuat.dart';
import '../../widgets/form_data_produk.dart';
import '../../widgets/kartu_rekomendasi_harga.dart';
import '../../widgets/kartu_review_upload.dart';
import '../../widgets/pilih_foto.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';

// Upload stok langkah 2 & 3 (penjual):
// Langkah 2: Data Produk (form OCR / manual / draf lokal)
// Langkah 3: Review Data, Ubah Harga Awal Manual, & Terbitkan (T7)
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
  ListingModel? _draftServer;
  PriceAdviceModel? _saranHarga;

  DateTime get _tanggalPalingAwal =>
      DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    nomorBatchController.text =
        'LOT-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final InvoiceItemModel? item = widget.itemFaktur;
    final DraftListingModel? draft = widget.draft;
    if (item != null) {
      namaController.text = item.namaProduk;
      merekController.text = item.merek ?? '';
      jumlahController.text = '${item.jumlah}';
      hargaNormalController.text = item.hargaNormal.round().toString();
      hargaMinimumController.text = (item.hargaNormal * 0.3).round().toString();
      if (FormDataProduk.daftarKategori.contains(item.kategori)) {
        _kategori = item.kategori;
      }
      if (FormDataProduk.daftarSatuan.contains(item.satuan)) {
        _satuan = item.satuan;
      }
      _aturTanggal(item.tanggalKedaluwarsa);
    } else if (draft != null) {
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
    final TextEditingController hargaAwalCtrl = TextEditingController(
      text: hargaAwalSekarang.round().toString(),
    );

    final double batasBawah =
        _saranHarga!.batasBawah ?? (_saranHarga!.hargaSaran * 0.8);
    final double batasAtas =
        _saranHarga!.batasAtas ?? (_saranHarga!.hargaSaran * 1.2);

    final bool? simpan = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final double? nilaiInput = double.tryParse(hargaAwalCtrl.text);
            final bool diLuarRentang = nilaiInput != null &&
                (nilaiInput < batasBawah || nilaiInput > batasAtas);

            return AlertDialog(
              title: const Text('Ubah Harga Awal Manual'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tentukan harga mulai lelang sebelum diterbitkan.',
                      style: TextStyle(
                        fontSize: AppTheme.fontKecil,
                        color: AppTheme.warnaTeksRedup,
                      ),
                    ),
                    const SizedBox(height: AppTheme.jarakKecil),
                    Text(
                      'Rentang wajar AI: ${ListingModel.formatRupiah(batasBawah)} – ${ListingModel.formatRupiah(batasAtas)}',
                      style: const TextStyle(
                        fontSize: AppTheme.fontKecil,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warnaUtama,
                      ),
                    ),
                    const SizedBox(height: AppTheme.jarakSedang),
                    TextField(
                      controller: hargaAwalCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Harga Mulai Lelang (Rp)',
                        prefixText: 'Rp ',
                      ),
                    ),
                    if (diLuarRentang) ...[
                      const SizedBox(height: AppTheme.jarakKecil),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.jarakKecil),
                        decoration: BoxDecoration(
                          color: AppTheme.warnaAksen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          border: Border.all(
                            color: AppTheme.warnaAksen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: AppTheme.warnaAksen,
                            ),
                            SizedBox(width: AppTheme.jarakKecil),
                            Expanded(
                              child: Text(
                                'Peringatan: Harga berada di luar rentang saran AI. Anda akan diminta menyetujui konfirmasi saat menerbitkan.',
                                style: TextStyle(
                                  fontSize: AppTheme.fontKecil,
                                  color: AppTheme.warnaAksen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (simpan != true || !mounted) return;

    final double? hargaBaru = double.tryParse(hargaAwalCtrl.text);
    if (hargaBaru == null || hargaBaru <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan angka harga yang valid')),
      );
      return;
    }

    tampilkanDialogMemuat(context, pesan: 'Menyimpan harga awal baru...');
    try {
      final ListingModel updated = await ApiService.ubahDraft(
        _draftServer!.id,
        {'start_price': hargaBaru},
      );
      final PriceAdviceModel saranBaru =
          await ApiService.ambilRekomendasiHarga(_draftServer!.id);
      if (!mounted) return;
      Navigator.pop(context); // tutup dialog
      setState(() {
        _draftServer = updated;
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
      appBar: AppBarUpload(langkahAktif: tahapForm ? 2 : 3),
      body: tahapForm ? _buatForm() : _buatTahapTerbit(),
      bottomNavigationBar: BarBawahKaca(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppTheme.tinggiTombol)),
                onPressed: _sedangMemproses
                    ? null
                    : (tahapForm ? _simpanDraftLokal : _bukaDialogUbahHargaAwal),
                child: Text(tahapForm ? 'Simpan draft' : 'Atur manual'),
              ),
            ),
            const SizedBox(width: AppTheme.jarakKecil),
            Expanded(
              flex: 2,
              child: tahapForm
                  ? PrimaryButton(
                      teks: 'Lanjut ke harga',
                      sedangMemuat: _sedangMemproses,
                      onPressed: _lanjutKeRekomendasi,
                    )
                  : PrimaryButton(teks: 'Terbitkan', ikon: Icons.check, onPressed: _terbitkan),
            ),
          ],
        ),
      ),
    );
  }

  // Tahap 3: ringkasan data, kartu rekomendasi harga; tombol ada di bar bawah.
  Widget _buatTahapTerbit() {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.jarakTepi),
      children: [
        KartuReviewUpload(
          draft: _draftServer!,
          fotoLokal: _fotoProduk,
          onUbahHargaAwal: _bukaDialogUbahHargaAwal,
        ),
        KartuRekomendasiHarga(saran: _saranHarga!, draft: _draftServer!),
        const SizedBox(height: AppTheme.jarakKecil),
        const Text(
          'Belum ingin terbit? Draft ini tetap tersimpan di server dan bisa diedit kembali dari halaman Stok.',
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
