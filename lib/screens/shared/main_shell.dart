import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/favorit_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../../widgets/dialog_memuat.dart';
import '../buyer/catalog_screen.dart';
import 'orders_screen.dart';

// Kerangka utama setelah login: BottomNavigationBar dengan 4 tab per peran.
// Isi tab masih sementara; tiap tab diganti layar aslinya di langkah berikutnya.
// Tombol logout di AppBar juga sementara, nanti pindah ke layar Profil.
class MainShell extends StatefulWidget {
  final String peran; // 'seller' atau 'buyer', dikirim dari login/register/splash

  const MainShell({super.key, required this.peran});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  bool get isPenjual => widget.peran == 'seller';

  // Judul tab sesuai peran (panduan 3.2 dan 3.3).
  List<String> get _judulTab => isPenjual
      ? ['Dasbor', 'Stok', 'Game', 'Profil']
      : ['Katalog', 'Pesanan', 'Game', 'Profil'];

  List<IconData> get _ikonTab => isPenjual
      ? [Icons.dashboard_outlined, Icons.inventory_2_outlined, Icons.sports_esports_outlined, Icons.person_outline]
      : [Icons.storefront_outlined, Icons.receipt_long_outlined, Icons.sports_esports_outlined, Icons.person_outline];

  // Array halaman: yang tampil = _pages[_selectedIndex].
  // _HalamanSementara diganti layar asli di langkah berikutnya.
  List<Widget> get _pages => isPenjual
      ? const [
          _HalamanSementara(judul: 'Dasbor'),
          _HalamanSementara(judul: 'Stok'),
          _HalamanSementara(judul: 'Game'),
          _HalamanSementara(judul: 'Profil'),
        ]
      : const [
          CatalogScreen(),
          OrdersScreen(isPenjual: false),
          _HalamanSementara(judul: 'Game'),
          _HalamanSementara(judul: 'Profil'),
        ];

  // Konfirmasi -> dialog loading (buffer) -> logout di server -> kembali ke Login.
  Future<void> _keluar() async {
    final bool? yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (yakin != true || !mounted) return;

    tampilkanDialogMemuat(context, pesan: 'Sedang keluar...');
    await ApiService.keluar();
    if (!mounted) return;
    // pushAndRemoveUntil di dalamnya ikut menutup dialog loading.
    await kembaliKeLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_judulTab[_selectedIndex]),
        actions: [
          // Ikon Favorit + badge jumlah, hanya untuk pembeli.
          if (!isPenjual) const _IkonFavorit(),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: _keluar,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.warnaUtama,
        onTap: (indeks) => setState(() => _selectedIndex = indeks),
        items: List.generate(
          _judulTab.length,
          (i) => BottomNavigationBarItem(icon: Icon(_ikonTab[i]), label: _judulTab[i]),
        ),
      ),
    );
  }
}

// Ikon hati di AppBar dengan badge jumlah favorit.
// Get.find mengambil controller yang sama dengan kartu katalog,
// jadi angka badge ikut berubah saat hati diketuk di mana pun (Obx).
// Ketuk -> named route GetX ke halaman Favorit.
class _IkonFavorit extends StatelessWidget {
  const _IkonFavorit();

  @override
  Widget build(BuildContext context) {
    final FavoritController favoritController = Get.find<FavoritController>();

    return IconButton(
      tooltip: 'Favorit',
      onPressed: () => Get.toNamed(AppRoutes.favorit),
      icon: Obx(() => Badge(
            isLabelVisible: favoritController.jumlahFavorit > 0,
            label: Text('${favoritController.jumlahFavorit}'),
            child: const Icon(Icons.favorite_border),
          )),
    );
  }
}

// Isi tab sementara sampai layar aslinya dibuat.
class _HalamanSementara extends StatelessWidget {
  final String judul;

  const _HalamanSementara({required this.judul});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Halaman $judul (segera dibuat)', style: AppTheme.gayaTeksRedup),
    );
  }
}
