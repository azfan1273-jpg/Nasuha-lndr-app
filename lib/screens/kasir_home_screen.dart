import 'package:pocketbase/pocketbase.dart';
import '../main.dart'; // <--- Agar variabel 'pb' dari main.dart terbaca di sini!
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lndr_kasir/providers/settings_provider.dart';

class KasirHomeScreen extends StatefulWidget {
  const KasirHomeScreen({super.key});

  @override
  State<KasirHomeScreen> createState() => _KasirHomeScreenState();
}

class _KasirHomeScreenState extends State<KasirHomeScreen> {
  int _currentIndex = 0;
  int _orderFilterIndex = 0;
  int _reportTabFilterIndex = 0;

  // --- STATE DATA PELANGGAN ---
  final List<Map<String, String>> _customerList = [
    {'name': 'Fitria Sari', 'phone': '081234567890'},
    {'name': 'Budi Santoso', 'phone': '085678901234'},
    {'name': 'Citra Dewi', 'phone': '087890123456'},
  ];

  // --- STATE DATA KERANJANG & CUSTOMER TERPILIH ---
  Map<String, String>? _selectedCustomer;
  final List<Map<String, dynamic>> _cartItems = [];

  // --- STATE PENAMPUNG TRANSAKSI HARI INI ---
  final List<Map<String, dynamic>> _ordersHariIni = [];

  // Helper untuk menghitung total belanja di keranjang
  double get _totalPrice {
    return _cartItems.fold(0.0, (sum, item) => sum + (item['total'] as double));
  }

  // Helper untuk menghitung total omset transaksi masuk
  double get _totalOmsetHariIni {
    return _ordersHariIni.fold(
      0.0,
      (sum, item) => sum + (item['total'] as double),
    );
  }

  // --- DIALOG 1: PILIH ACTION TRANSAKSI ---
  void _showActionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aksi Cepat Transaksi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pilih menu transaksi yang ingin diproses',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Text(
                        'LNDR POS',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _buildElegantActionCard(
                      icon: Icons.add_shopping_cart_rounded,
                      accentColor: const Color(0xFF2563EB),
                      title: 'Tambah Transaksi',
                      subtitle: 'Buat order laundry baru',
                      onTap: () {
                        Navigator.pop(context);
                        _showBuatOrderDialog();
                      },
                    ),
                    _buildElegantActionCard(
                      icon: Icons.remove_circle_outline_rounded,
                      accentColor: const Color(0xFFEF4444),
                      title: 'Batalkan Transaksi',
                      subtitle: 'Pembatalan orderan',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildElegantActionCard(
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: const Color(0xFF10B981),
                      title: 'Catat Pengeluaran',
                      subtitle: 'Input beban operasional',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildElegantActionCard(
                      icon: Icons.card_giftcard_rounded,
                      accentColor: const Color(0xFFF59E0B),
                      title: 'Reward Pelanggan',
                      onTap: () => Navigator.pop(context),
                      subtitle: 'Klaim poin / voucher',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildElegantActionCard({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: accentColor.withOpacity(0.08),
        highlightColor: accentColor.withOpacity(0.04),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withOpacity(0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 8.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DIALOG 2: FORM BUAT ORDER TRANSAKSI (DENGAN DISKON) ---
  void _showBuatOrderDialog() {
    String selectedParfum = 'Standard / Original';
    double diskonPersen = 0.0; // Variable diskon

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Kalkulasi harga setelah diskon di tempat yang benar (sebelum return Widget)
            final double totalSetelahDiskon =
                _totalPrice - (_totalPrice * (diskonPersen / 100));

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 400,
                constraints: const BoxConstraints(maxHeight: 560),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Buat Order Transaksi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // PILIH CUSTOMER
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pelanggan',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedCustomer != null
                                        ? '${_selectedCustomer!['name']} (${_selectedCustomer!['phone']})'
                                        : 'Silahkan Pilih Customer Terlebih Dahulu.',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: _selectedCustomer != null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontStyle: _selectedCustomer == null
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                      color: _selectedCustomer != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () async {
                                await _showPilihCustomerDialog();
                                setModalState(() {});
                              },
                              child: const Text(
                                'CARI',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // KERANJANG LAYANAN
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daftar Layanan (Keranjang)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await _showPilihLayananDialog();
                                    setModalState(() {});
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.cyan[50],
                                    foregroundColor: Colors.cyan[800],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    '+ Tambah Layanan',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _cartItems.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'Belum ada layanan yang ditambahkan.',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _cartItems.length,
                                    itemBuilder: (context, index) {
                                      final cart = _cartItems[index];
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          cart['nama'],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Rp ${cart['harga'].toInt()} x ${cart['jumlah']}',
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Rp ${cart['total'].toInt()}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setModalState(() {
                                                  _cartItems.removeAt(index);
                                                });
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // AROMA PARFUM
                      const Text(
                        'Aroma Parfum',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedParfum,
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                            ),
                            items:
                                <String>[
                                  'Standard / Original',
                                  'Lily',
                                  'Akasia',
                                  'Ocean Fresh',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (newValue) {
                              setModalState(() {
                                selectedParfum = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // CATATAN ORDER
                      const Text(
                        'Catatan Order',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        maxLines: 2,
                        style: const TextStyle(fontSize: 11),
                        decoration: InputDecoration(
                          hintText:
                              'Contoh: Luntur, Jangan Terlalu Panas, Baju warna putih dipisah',
                          hintStyle: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // PANEL DISKON
                      const Text(
                        'Diskon / Potongan Harga',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: diskonPersen,
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 0.0,
                                child: Text('Tanpa Diskon (0%)'),
                              ),
                              DropdownMenuItem(
                                value: 5.0,
                                child: Text('Diskon 5%'),
                              ),
                              DropdownMenuItem(
                                value: 10.0,
                                child: Text('Diskon 10%'),
                              ),
                              DropdownMenuItem(
                                value: 15.0,
                                child: Text('Diskon 15%'),
                              ),
                              DropdownMenuItem(
                                value: 20.0,
                                child: Text('Diskon 20%'),
                              ),
                            ],
                            onChanged: (newValue) {
                              setModalState(() {
                                diskonPersen = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // BOTTOM BUTTON & TOTAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL PRICE',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              if (diskonPersen > 0)
                                Text(
                                  'Rp ${_totalPrice.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.red,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                'Rp ${totalSetelahDiskon.toInt()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                _cartItems.isEmpty || _selectedCustomer == null
                                ? null
                                : () {
                                    setState(() {
                                      _ordersHariIni.insert(0, {
                                        'customer': _selectedCustomer!['name'],
                                        'phone': _selectedCustomer!['phone'],
                                        'total': totalSetelahDiskon,
                                        'itemCount': _cartItems.length,
                                        'status': 'Antrian',
                                      });
                                      _cartItems.clear();
                                      _selectedCustomer = null;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Order Transaksi Berhasil Dibuat!',
                                        ),
                                      ),
                                    );
                                    Navigator.pop(context);
                                  },
                            child: const Text(
                              'PESAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- DIALOG 3: PILIH CUSTOMER ---
  Future<void> _showPilihCustomerDialog() async {
    bool isAddingNewCustomer = false;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    String searchQuery = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setCustomerModalState) {
            final filteredList = _customerList.where((cust) {
              final name = cust['name']!.toLowerCase();
              final phone = cust['phone']!;
              final q = searchQuery.toLowerCase();
              return name.contains(q) || phone.contains(q);
            }).toList();

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 340,
                constraints: const BoxConstraints(maxHeight: 520),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pilih Customer',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        style: const TextStyle(fontSize: 11),
                        onChanged: (val) {
                          setCustomerModalState(() {
                            searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Masukkan Nama atau No Hp',
                          hintStyle: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          suffixIcon: const Icon(Icons.search, size: 16),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (filteredList.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Pelanggan tidak ditemukan.',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 140),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: filteredList.length,
                            separatorBuilder: (ctx, i) =>
                                const Divider(height: 1),
                            itemBuilder: (ctx, index) {
                              final cust = filteredList[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  cust['name']!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  cust['phone']!,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedCustomer = cust;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAddingNewCustomer
                                ? Colors.grey[600]
                                : Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            setCustomerModalState(() {
                              isAddingNewCustomer = !isAddingNewCustomer;
                            });
                          },
                          child: Text(
                            isAddingNewCustomer
                                ? 'BATAL TAMBAH'
                                : 'TAMBAH CUSTOMER BARU',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      if (isAddingNewCustomer) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[50]!.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: nameController,
                                style: const TextStyle(fontSize: 11),
                                decoration: InputDecoration(
                                  hintText: 'Nama Pelanggan Baru',
                                  hintStyle: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: phoneController,
                                style: const TextStyle(fontSize: 11),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'No HP / WhatsApp',
                                  hintStyle: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (nameController.text.isNotEmpty) {
                                      final newCust = {
                                        'name': nameController.text,
                                        'phone': phoneController.text.isEmpty
                                            ? '-'
                                            : phoneController.text,
                                      };
                                      setState(() {
                                        _customerList.insert(0, newCust);
                                        _selectedCustomer = newCust;
                                      });
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text(
                                    'Simpan Customer',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
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
              ),
            );
          },
        );
      },
    );
  }

  // --- DIALOG 4: PILIH LAYANAN ---
  Future<void> _showPilihLayananDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 360,
            constraints: const BoxConstraints(maxHeight: 520),
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Layanan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.settings,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextField(
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: 'Cari Layanan V2',
                    hintStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCategoryGroup('LAYANAN KILOAN (3)', [
                        {
                          'name': 'setrika',
                          'price': 'Rp 4.000 / Kg',
                          'est': 'Est: 6 Hari',
                        },
                        {
                          'name': 'cuci lipat',
                          'price': 'Rp 6.000 / Kg',
                          'est': 'Est: 4 Hari',
                        },
                        {
                          'name': 'cuci kering',
                          'price': 'Rp 10.000 / Kg',
                          'est': 'Est: 4 Hari',
                        },
                      ]),
                      const SizedBox(height: 10),

                      _buildCategoryGroup('LAYANAN SATUAN (2)', [
                        {
                          'name': 'Cuci Sepatu Premium',
                          'price': 'Rp 25.000 / Pasang',
                          'est': 'Est: 2 Hari',
                        },
                        {
                          'name': 'Cuci Jaket Kulit',
                          'price': 'Rp 35.000 / Pcs',
                          'est': 'Est: 3 Hari',
                        },
                      ]),
                      const SizedBox(height: 10),

                      _buildCategoryGroup('LAYANAN PCS (2)', [
                        {
                          'name': 'Cuci Bedcover Large',
                          'price': 'Rp 30.000 / Pcs',
                          'est': 'Est: 1 Hari',
                        },
                        {
                          'name': 'Cuci Selimut',
                          'price': 'Rp 15.000 / Pcs',
                          'est': 'Est: 1 Hari',
                        },
                      ]),
                      const SizedBox(height: 10),

                      _buildCategoryGroup('LAYANAN METER (1)', [
                        {
                          'name': 'Cuci Karpet Tebal',
                          'price': 'Rp 15.000 / Meter',
                          'est': 'Est: 3 Hari',
                        },
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryGroup(String title, List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name']!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item['price']} • ${item['est']}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        final double hargaNum =
                            double.tryParse(
                              item['price']!.replaceAll(RegExp(r'[^0-9]'), ''),
                            ) ??
                            0;

                        setState(() {
                          _cartItems.add({
                            'nama': item['name'],
                            'harga': hargaNum,
                            'jumlah': 1.0,
                            'total': hargaNum,
                          });
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item['name']} ditambahkan ke keranjang!',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text(
                        '+ Pilih',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showKelolaLayananDialog() {
    String selectedUnit = 'Kg';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLayananState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 380,
                constraints: const BoxConstraints(maxHeight: 620),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kelola Daftar Layanan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.add,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Tambah Layanan Baru',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            TextField(
                              style: const TextStyle(fontSize: 11),
                              decoration: InputDecoration(
                                hintText:
                                    'Nama Layanan (Contoh: Cuci Kiloan Express)',
                                hintStyle: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    style: const TextStyle(fontSize: 11),
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'Harga (Rp)',
                                      hintStyle: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedUnit,
                                        isExpanded: true,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black,
                                        ),
                                        items: <String>['Kg', 'Pcs', 'Meter']
                                            .map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            })
                                            .toList(),
                                        onChanged: (newValue) {
                                          setLayananState(() {
                                            selectedUnit = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            TextField(
                              style: const TextStyle(fontSize: 11),
                              decoration: InputDecoration(
                                hintText:
                                    'Estimasi Selesai (Hari / misal: 1 atau 0.5)',
                                hintStyle: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            const Text(
                              'Daftar Layanan Tersedia',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),

                            Container(
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Scrollbar(
                                child: ListView(
                                  padding: const EdgeInsets.all(6),
                                  children: [
                                    _buildLayananItem(
                                      'Cuci Kiloan Express',
                                      'Rp 10.000 / Kg',
                                      '1 Hari',
                                    ),
                                    _buildLayananItem(
                                      'Cuci Kering Lipat',
                                      'Rp 6.000 / Kg',
                                      '2 Hari',
                                    ),
                                    _buildLayananItem(
                                      'Setrika Saja',
                                      'Rp 5.000 / Kg',
                                      '0.5 Hari',
                                    ),
                                    _buildLayananItem(
                                      'Cuci Bedcover Large',
                                      'Rp 35.000 / Pcs',
                                      '2 Hari',
                                    ),
                                    _buildLayananItem(
                                      'Cuci Sepatu Premium',
                                      'Rp 30.000 / Pcs',
                                      '3 Hari',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Simpan Layanan Baru',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLayananItem(
    String title,
    String price, [
    String estimasi = '-',
  ]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (estimasi != '-') ...[
                      const SizedBox(width: 8),
                      Text(
                        '• $estimasi',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 15, color: Colors.red),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Center(
        child: Container(
          width: 390,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                color: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.amber,
                            child: Icon(
                              Icons.store,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    settings.namaToko,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      settings.userRole,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                settings.emailToko,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text(
                          'Refresh',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildBerandaTab(),
                    _buildOrderTab(),
                    _buildReportTab(),
                    _buildPengaturanTab(settings),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _showActionDialog(),
                    child: const Text(
                      'MENU TRANSAKSI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color(0xFF2563EB),
                  unselectedItemColor: Colors.grey,
                  selectedLabelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 10),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Beranda',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart),
                      label: 'Order',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.insert_chart),
                      label: 'Report',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Pengaturan',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. ORDER TAB (Menampilkan Pelanggan Sesuai Status)
  Widget _buildOrderTab() {
    final List<String> statusFilter = ['Antrian', 'Proses', 'Selesai', 'Batal'];
    final String selectedStatus = statusFilter[_orderFilterIndex];

    // Filter daftar orderan berdasarkan tab status yang dipilih
    final filteredOrders = _ordersHariIni
        .where((o) => o['status'] == selectedStatus)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Daftar Order Pelanggan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Klik item untuk melihat detail & memproses',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFBFDBFE),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long_rounded,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TOTAL TRANSAKSI',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E40AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${_customerList.where((o) => o['status'] == 'Antrian' || o['status'] == 'Proses' || o['status'] == 'Selesai').length} Order',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildSubTab(
                  'Antrian',
                  0,
                  _orderFilterIndex,
                  (idx) => setState(() => _orderFilterIndex = idx),
                ),
                _buildSubTab(
                  'Proses',
                  1,
                  _orderFilterIndex,
                  (idx) => setState(() => _orderFilterIndex = idx),
                ),
                _buildSubTab(
                  'Selesai',
                  2,
                  _orderFilterIndex,
                  (idx) => setState(() => _orderFilterIndex = idx),
                ),
                _buildSubTab(
                  'Batal',
                  3,
                  _orderFilterIndex,
                  (idx) => setState(() => _orderFilterIndex = idx),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada orderan di status ini.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey[200]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFFEFF6FF),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            order['customer'] ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            '${order['phone']} • ${order['itemCount']} Layanan',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rp ${(order['total'] as double).toInt()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Lihat Detail >',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showDetailOrderDialog(order),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // DIALOG DETAIL ORDER PELANGGAN (SESUAI GAMBAR 2)
  void _showDetailOrderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 400,
                constraints: const BoxConstraints(maxHeight: 620),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Detail Order Pelanggan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Nota #000001',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // PELANGGAN
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PELANGGAN',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order['customer'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  order['phone'] ?? '-',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // DAFTAR LAYANAN
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DAFTAR LAYANAN / ITEM',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Cuci & Setrika Komplit',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      '${order['itemCount']} Layanan',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Rp ${(order['total'] as double).toInt()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // PARFUM & STATUS PEMBAYARAN
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'AROMA PARFUM',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Standard / Original',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'STATUS PEMBAYARAN',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Belum Lunas',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // TANGGAL & ESTIMASI (OTOMATIS SESUAI HARI INI)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TANGGAL MASUK',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFDE68A),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ESTIMASI SELESAI',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    // Default estimasi +2 hari dari tanggal masuk
                                    '${DateTime.now().add(const Duration(days: 2)).day}/${DateTime.now().add(const Duration(days: 2)).month}/${DateTime.now().year}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // CATATAN ORDER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'CATATAN ORDER',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tidak ada catatan',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TOMBOL AKSI UPDATE STATUS (ANTRIAN -> PROSES -> SELESAI)
                      if (order['status'] == 'Antrian') ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                order['status'] = 'Proses';
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order dipindahkan ke Proses!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bolt, size: 16),
                            label: const Text(
                              '⚡ Lanjut Proses Order (Ke Proses)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ] else if (order['status'] == 'Proses') ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                order['status'] = 'Selesai';
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Order Selesai!')),
                              );
                            },
                            icon: const Icon(Icons.check_circle, size: 16),
                            label: const Text(
                              '✔ Selesaikan Order (Ke Selesai)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // TOMBOL KIRIM WA NOTIFIKASI
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {},
                          icon: const Icon(Icons.chat, size: 16),
                          label: const Text(
                            '📲 Kirim WA Notifikasi Selesai',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TOMBOL BATALKAN ORDER & EDIT LAYANAN
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFEE2E2),
                                foregroundColor: const Color(0xFFDC2626),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                _showKonfirmasiBatalDialog(order);
                              },
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text(
                                'Batalkan Order',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEFF6FF),
                                foregroundColor: const Color(0xFF2563EB),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                _showEditLayananDialog(order);
                              },
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text(
                                'Edit Layanan',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // TOTAL PRICE & BAYAR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL PRICE',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Rp ${(order['total'] as double).toInt()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.payments, size: 14),
                            label: const Text(
                              'BAYAR NOW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // DIALOG LIST ORDERAN BERDASARKAN RINGKASAN CUCIAN
  void _showRingkasanOrderDialog(
    String title,
    List<Map<String, dynamic>> listOrder,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 380,
            constraints: const BoxConstraints(maxHeight: 480),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: listOrder.isEmpty
                      ? const Center(
                          child: Text(
                            'Tidak ada orderan di kategori ini.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: listOrder.length,
                          itemBuilder: (context, index) {
                            final order = listOrder[index];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.local_laundry_service,
                                  color: Color(0xFF2563EB),
                                  size: 18,
                                ),
                                title: Text(
                                  order['customer'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                subtitle: Text(
                                  '${order['itemCount']} Layanan • Rp ${(order['total'] as double).toInt()}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    order['status'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context); // Tutup ringkasan
                                  _showDetailOrderDialog(
                                    order,
                                  ); // Buka detail order
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // DIALOG KONFIRMASI BATAL TRANSAKSI
  void _showKonfirmasiBatalDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi Pembatalan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah anda yakin membatalkan transaksi untuk "${order['customer']}"?',
            style: const TextStyle(fontSize: 11),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'TIDAK',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  order['status'] = 'Batal'; // Pindah status ke daftar Batal
                });
                Navigator.pop(context); // Tutup Dialog Konfirmasi
                Navigator.pop(context); // Tutup Dialog Detail Order
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Transaksi ${order['customer']} berhasil dibatalkan!',
                    ),
                  ),
                );
              },
              child: const Text(
                'YA, BATALKAN',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // DIALOG EDIT ORDER TRANSAKSI (MIRIP FORM BUAT ORDER)
  void _showEditLayananDialog(Map<String, dynamic> order) {
    String selectedParfum = 'Standard / Original';
    double diskonPersen = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double totalSetelahDiskon =
                _totalPrice - (_totalPrice * (diskonPersen / 100));

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 400,
                constraints: const BoxConstraints(maxHeight: 560),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Edit Order Transaksi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // PELANGGAN (NAMA TIDAK BISA DIUBAH / READ-ONLY, TOMBOL CARI DIHILANGKAN)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pelanggan',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order['customer'] ?? '-'} (${order['phone'] ?? '-'})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // KERANJANG LAYANAN
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daftar Layanan (Keranjang)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await _showPilihLayananDialog();
                                    setModalState(() {});
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.cyan[50],
                                    foregroundColor: Colors.cyan[800],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    '+ Tambah Layanan',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _cartItems.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'Belum ada layanan yang ditambahkan.',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _cartItems.length,
                                    itemBuilder: (context, index) {
                                      final cart = _cartItems[index];
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          cart['nama'],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Rp ${cart['harga'].toInt()} x ${cart['jumlah']}',
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Rp ${cart['total'].toInt()}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 16,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                setModalState(() {
                                                  _cartItems.removeAt(index);
                                                });
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // AROMA PARFUM
                      const Text(
                        'Aroma Parfum',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedParfum,
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                            ),
                            items:
                                <String>[
                                  'Standard / Original',
                                  'Lily',
                                  'Akasia',
                                  'Ocean Fresh',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (newValue) {
                              setModalState(() {
                                selectedParfum = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // CATATAN ORDER
                      const Text(
                        'Catatan Order',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        maxLines: 2,
                        style: const TextStyle(fontSize: 11),
                        decoration: InputDecoration(
                          hintText:
                              'Contoh: Luntur, Jangan Terlalu Panas, Baju warna putih dipisah',
                          hintStyle: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // PANEL DISKON
                      const Text(
                        'Diskon / Potongan Harga',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: diskonPersen,
                            isExpanded: true,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 0.0,
                                child: Text('Tanpa Diskon (0%)'),
                              ),
                              DropdownMenuItem(
                                value: 5.0,
                                child: Text('Diskon 5%'),
                              ),
                              DropdownMenuItem(
                                value: 10.0,
                                child: Text('Diskon 10%'),
                              ),
                              DropdownMenuItem(
                                value: 15.0,
                                child: Text('Diskon 15%'),
                              ),
                              DropdownMenuItem(
                                value: 20.0,
                                child: Text('Diskon 20%'),
                              ),
                            ],
                            onChanged: (newValue) {
                              setModalState(() {
                                diskonPersen = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // BOTTOM BUTTON & TOTAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL PRICE',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              if (diskonPersen > 0)
                                Text(
                                  'Rp ${_totalPrice.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.red,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                'Rp ${totalSetelahDiskon.toInt()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_cartItems.isNotEmpty) {
                                  order['total'] = totalSetelahDiskon;
                                  order['itemCount'] = _cartItems.length;
                                }
                              });
                              Navigator.pop(context); // Tutup dialog edit
                              Navigator.pop(context); // Refresh dialog detail
                              _showDetailOrderDialog(order);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Detail order berhasil diperbarui!',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'SIMPAN PERUBAHAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. REPORT TAB (Laporan Keuangan & Pelanggan Dinamis)
  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📊 LAPORAN HARI INI',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _buildStatCard(
                'OMSET',
                'Rp ${_totalOmsetHariIni.toInt()}',
                Colors.amber[50]!,
                Colors.amber[800]!,
                Icons.monetization_on,
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                'PENDAPATAN',
                'Rp ${_totalOmsetHariIni.toInt()}',
                Colors.green[50]!,
                Colors.green[700]!,
                Icons.trending_up,
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                'PENGELUARAN',
                'Rp 0',
                Colors.red[50]!,
                Colors.red[700]!,
                Icons.shopping_bag,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildStatCard(
                'ORDER HARI INI',
                '${_ordersHariIni.length}',
                Colors.blue[50]!,
                Colors.blue[700]!,
                Icons.inventory_2,
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                'SELESAI HARI INI',
                '0',
                Colors.teal[50]!,
                Colors.teal[700]!,
                Icons.check_circle,
              ),
              const SizedBox(width: 6),
              _buildStatCard(
                'BATAL HARI INI',
                '0',
                Colors.pink[50]!,
                Colors.pink[700]!,
                Icons.cancel,
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Laporan Keuangan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // TOGGLE TAB SUB-MENU
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildSubTab(
                  'Transaksi',
                  0,
                  _reportTabFilterIndex,
                  (idx) => setState(() => _reportTabFilterIndex = idx),
                ),
                _buildSubTab(
                  'Laporan Keuangan',
                  1,
                  _reportTabFilterIndex,
                  (idx) => setState(() => _reportTabFilterIndex = idx),
                ),
                _buildSubTab(
                  'Pelanggan',
                  2,
                  _reportTabFilterIndex,
                  (idx) => setState(() => _reportTabFilterIndex = idx),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // TAMPILAN DINAMIS SESUAI SUB-TAB YANG DIPILIH
          if (_reportTabFilterIndex == 0) ...[
            // ITEM SUB-TAB TRANSAKSI
            _buildMenuItem(
              Icons.bar_chart,
              Colors.green,
              'Semua Transaksi',
              'Lihat seluruh riwayat orderan laundry',
              () => _showDefaultPage('Semua Transaksi'),
            ),
            _buildMenuItem(
              Icons.grid_view,
              Colors.amber[700]!,
              'Transaksi per Layanan',
              'Laporan orderan berdasarkan jenis layanan',
              () => _showDefaultPage('Transaksi per Layanan'),
            ),
            _buildMenuItem(
              Icons.hourglass_bottom,
              Colors.orange,
              'Transaksi Belum Selesai',
              'Daftar orderan aktif / antrian / proses',
              () => _showDefaultPage('Transaksi Belum Selesai'),
            ),
            _buildMenuItem(
              Icons.check_box,
              Colors.green,
              'Transaksi Selesai',
              'Daftar orderan yang sudah rampung',
              () => _showDefaultPage('Transaksi Selesai'),
            ),
            _buildMenuItem(
              Icons.disabled_by_default,
              Colors.red,
              'Transaksi Batal',
              'Daftar orderan yang telah dibatalkan',
              () => _showDefaultPage('Transaksi Batal'),
            ),
          ] else if (_reportTabFilterIndex == 1) ...[
            // ITEM SUB-TAB LAPORAN KEUANGAN
            _buildMenuItem(
              Icons.account_balance_wallet,
              Colors.blue,
              'Arus Kas / Cashflow',
              'Laporan pemasukan & pengeluaran toko',
              () => _showDefaultPage('Arus Kas / Cashflow'),
            ),
            _buildMenuItem(
              Icons.pie_chart,
              Colors.purple,
              'Laporan Laba Rugi',
              'Ringkasan profit bersih operasional',
              () => _showDefaultPage('Laporan Laba Rugi'),
            ),
          ] else if (_reportTabFilterIndex == 2) ...[
            // ITEM SUB-TAB PELANGGAN (PERSIS SEPERTI GAMBAR)
            _buildMenuItem(
              Icons.people_alt,
              Colors.blueGrey,
              'Ringkasan Pelanggan',
              'Total statistik dan gambaran umum customer',
              () => _showDefaultPage('Ringkasan Pelanggan'),
            ),
            _buildMenuItem(
              Icons.description,
              Colors.blue,
              'Detail Pelanggan',
              'Daftar kontak & histori order tiap customer',
              () => _showDefaultPage('Detail Pelanggan'),
            ),
            _buildMenuItem(
              Icons.workspace_premium,
              Colors.amber[800]!,
              'Top Customer',
              'Pelanggan paling sering / terbanyak order',
              () => _showDefaultPage('Top Customer'),
            ),
            _buildMenuItem(
              Icons.card_giftcard,
              Colors.redAccent,
              'Reward Pelanggan',
              'Poin / program promo & kesetiaan',
              () => _showDefaultPage('Reward Pelanggan'),
            ),
          ],
        ],
      ),
    );
  }

  // 4. PENGATURAN TAB
  Widget _buildPengaturanTab(SettingsProvider settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Toko & Kasir',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Akun Aktif (Email)',
                      style: TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                    SizedBox(height: 2),
                    Text(
                      settings.emailToko,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    settings.userRole,
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          _buildSettingCard(
            title: 'Kelola Daftar Layanan',
            subtitle: 'Tambah atau hapus layanan & harga laundry',
            bgColor: Colors.blue[50]!,
            btnColor: const Color(0xFF2563EB),
            onPressed: () => _showKelolaLayananDialog(),
          ),
          SizedBox(height: 10),

          _buildSettingCard(
            title: 'Kelola Aroma Parfum',
            subtitle: 'Tambah atau hapus varian aroma parfum toko',
            bgColor: Colors.green[50]!,
            btnColor: Colors.green[700]!,
            onPressed: () {},
          ),
          SizedBox(height: 10),

          _buildSettingCard(
            title: 'Kelola Akun',
            subtitle: 'Buka analitik traffic & manajemen toko',
            bgColor: Colors.indigo[50]!,
            btnColor: Colors.indigo[700]!,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AccountSettingsScreen(
                    ordersHariIni: _ordersHariIni,
                    userEmail: settings.emailToko,
                  ),
                ),
              );
            },
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Database Server',
                  style: TextStyle(fontSize: 9, color: Colors.grey),
                ),
                SizedBox(height: 2),
                Text(
                  'Supabase Cloud Multi-Tenant Active',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.logout, size: 16),
              label: const Text(
                'LOG OUT DARI AKUN',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildStatCard(
    String title,
    String value,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGridItem(
    String title,
    String value,
    Color bgColor,
    Color textColor,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                Icon(icon, size: 18, color: textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(
    String label,
    int index,
    int selectedIndex,
    Function(int) onTap,
  ) {
    final bool isActive = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Color bgColor,
    required Color btnColor,
    VoidCallback? onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 9, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: btnColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onPressed ?? () {},
            child: const Text(
              'Buka',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDefaultPage(String title) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 20),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction,
                        size: 40,
                        color: Colors.amber[800],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Halaman $title',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Halaman ini siap untuk diisi dengan fitur & UI baru.',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- FUNGSI BERANDA TAB YANG HILANG ---
  Widget _buildBerandaTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BANNER PROMO
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Text('📢 ', style: TextStyle(fontSize: 16)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Promo Cuci Komplit Diskon 10%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        Text(
                          'Berlaku sampai akhir bulan. Yuk tingkatkan omzet!',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // RINGKASAN CUCIAN
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.assignment_outlined,
                            color: Color(0xFF2563EB),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'RINGKASAN CUCIAN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.green,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Realtime',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatGridItem(
                        'CUCIAN AKTIF',
                        '${_ordersHariIni.where((o) => o['status'] == 'Antrian' || o['status'] == 'Proses').length}',
                        const Color(0xFFEFF6FF),
                        const Color(0xFF2563EB),
                        Icons.local_laundry_service,
                        () {
                          final listAktif = _ordersHariIni
                              .where(
                                (o) =>
                                    o['status'] == 'Antrian' ||
                                    o['status'] == 'Proses',
                              )
                              .toList();
                          _showRingkasanOrderDialog(
                            'Cucian Aktif (Antrian & Proses)',
                            listAktif,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildStatGridItem(
                        'HARUS SELESAI',
                        '0',
                        const Color(0xFFFEF3C7),
                        const Color(0xFFD97706),
                        Icons.timer_outlined,
                        () {
                          final listHarusSelesai = _ordersHariIni
                              .where(
                                (o) =>
                                    o['status'] != 'Selesai' &&
                                    o['status'] != 'Batal',
                              )
                              .toList();
                          _showRingkasanOrderDialog(
                            'Harus Selesai Hari Ini',
                            listHarusSelesai,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatGridItem(
                        'TERLAMBAT',
                        '0',
                        const Color(0xFFFEE2E2),
                        const Color(0xFFDC2626),
                        Icons.warning_amber_rounded,
                        () {
                          final listTerlambat = <Map<String, dynamic>>[];
                          _showRingkasanOrderDialog(
                            'Cucian Terlambat',
                            listTerlambat,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildStatGridItem(
                        'SELESAI',
                        '${_ordersHariIni.where((o) => o['status'] == 'Selesai').length}',
                        const Color(0xFFDCFCE7),
                        const Color(0xFF16A34A),
                        Icons.check_circle_outline,
                        () {
                          final listSelesai = _ordersHariIni
                              .where((o) => o['status'] == 'Selesai')
                              .toList();
                          _showRingkasanOrderDialog(
                            'Daftar Cucian Selesai',
                            listSelesai,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // KEUANGAN HARI INI
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '💸 KEUANGAN HARI INI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hari Ini',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Omset Hari Ini',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        'Rp ${_totalOmsetHariIni.toInt()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Pengeluaran Hari Ini',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      Text(
                        'Rp 0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // CARD MASUK HARI INI
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '☕ Masuk Hari Ini',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_ordersHariIni.length} Order',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ordersHariIni.isEmpty
                      ? Center(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Belum Ada Masuk Hari Ini',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Transaksi hari ini akan muncul di sini',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _ordersHariIni.length,
                          itemBuilder: (context, index) {
                            final order = _ordersHariIni[index];
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                dense: true,
                                leading: const CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Color(0xFFEFF6FF),
                                  child: Icon(
                                    Icons.local_laundry_service,
                                    color: Color(0xFF2563EB),
                                    size: 14,
                                  ),
                                ),
                                title: Text(
                                  order['customer'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                subtitle: Text(
                                  '${order['itemCount']} Layanan • Rp ${(order['total'] as double).toInt()}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFEF3C7),
                                    foregroundColor: const Color(0xFFD97706),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () =>
                                      _showKonfirmasiBatalDialog(order),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () => _showDetailOrderDialog(order),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} // <--- PENUTUP KELAS _KasirHomeScreenState

// ==========================================
// KELAS ACCOUNTSETTINGS (FULL REALTIME SUPABASE & STATE)
// ==========================================
class AccountSettingsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> ordersHariIni;
  final String userEmail;

  const AccountSettingsScreen({
    Key? key,
    required this.ordersHariIni,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final TextEditingController _targetController = TextEditingController();
  double _targetOmset = 15000000;
  bool _isLoadingTarget = true;

  // Realtime Permission Switches State
  bool _isManager = false;
  bool _canViewReport = true;
  bool _canManageServices = false;
  bool _canRecordExpense = true;
  bool _canEditDeleteOrder = false;

  @override
  void initState() {
    super.initState();
    _loadSettingsFromSupabase();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  // 1. TARIK DATA DARI SERVER LOKAL POCKETBASE
  Future<void> _loadSettingsFromSupabase() async {
      try {
        print('>>> MEMUAT DATA DARI POCKETBASE LOKAL...');
        
        // Ambil semua data store_settings tanpa filter email dulu (biar pasti dapet data pertama)
        final result = await pb.collection('store_settings').getList(
          page: 1,
          perPage: 1,
        );
  
        print('>>> HASIL FETCH POCKETBASE: ${result.items.length} record ditemukan');
  
        if (result.items.isNotEmpty) {
          final data = result.items.first.data;
          print('>>> DATA TERAMBIL: $data');
  
          if (mounted) {
            setState(() {
              _targetOmset = (data['target_omset'] as num?)?.toDouble() ?? 15000000;
              _isManager = data['is_manager'] ?? false;
              _canViewReport = data['can_view_report'] ?? true;
              _canManageServices = data['can_manage_services'] ?? false;
              _canRecordExpense = data['can_record_expense'] ?? true;
              _canEditDeleteOrder = data['can_edit_delete_order'] ?? false;
            });
          }
        } else {
          print('>>> POCKETBASE KOSONG: Menggunakan nilai default');
        }
      } catch (e) {
        print('>>> ERROR LOAD POCKETBASE: $e');
      } finally {
        if (mounted) setState(() => _isLoadingTarget = false);
      }
    }

  // 2. SIMPAN TARGET OMSET REALTIME KE SERVER LOKAL
  Future<void> _updateTarget() async {
      final cleanInput = _targetController.text.replaceAll('.', '').replaceAll(',', '');
      final newTarget = double.tryParse(cleanInput);
  
      if (newTarget != null && newTarget > 0) {
        try {
          print('>>> MEMPROSES SIMPAN TARGET: $newTarget');
  
          // 1. Cek apakah record sudah ada
          final result = await pb.collection('store_settings').getList(
            page: 1,
            perPage: 1,
          );
  
          if (result.items.isNotEmpty) {
            // UPDATE DATA YANG SUDAH ADA
            final id = result.items.first.id;
            await pb.collection('store_settings').update(id, body: {
              'target_omset': newTarget,
            });
            print('>>> BERHASIL UPDATE RECORD ID: $id');
          } else {
            // BUAT DATA BARU JIKA TABEL MASIH KOSONG
            final newRecord = await pb.collection('store_settings').create(body: {
              'user_email': widget.userEmail,
              'target_omset': newTarget,
            });
            print('>>> BERHASIL CREATE RECORD BARU ID: ${newRecord.id}');
          }
  
          if (mounted) {
            setState(() {
              _targetOmset = newTarget;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Target tersimpan di Server Lokal: Rp ${newTarget.toInt()}'),
                backgroundColor: const Color(0xFF16A34A),
              ),
            );
          }
          _targetController.clear();
        } catch (e) {
          print('>>> ERROR SAAT SIMPAN KE POCKETBASE: $e');
        }
      }
    }

  // 1. TARIK DATA SETTINGS & PERMISSION REALTIME DARI SUPABASE
  /* Future<void> _loadSettingsFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('store_settings')
          .select()
          .eq('user_email', widget.userEmail)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _targetOmset =
              (response['target_omset'] as num?)?.toDouble() ?? 15000000;
          _isManager = response['is_manager'] ?? false;
          _canViewReport = response['can_view_report'] ?? true;
          _canManageServices = response['can_manage_services'] ?? false;
          _canRecordExpense = response['can_record_expense'] ?? true;
          _canEditDeleteOrder = response['can_edit_delete_order'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Gagal sync data dari Supabase, memuat dari memori lokal: $e');
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _targetOmset = prefs.getDouble('target_omset_bulanan') ?? 15000000;
      });
    } finally {
      if (mounted) setState(() => _isLoadingTarget = false);
    }
  }

  // 2. SIMPAN TARGET OMSET REALTIME KE SUPABASE + LOKAL
  Future<void> _updateTarget() async {
    final cleanInput = _targetController.text
        .replaceAll('.', '')
        .replaceAll(',', '');
    final newTarget = double.tryParse(cleanInput);

    if (newTarget != null && newTarget > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('target_omset_bulanan', newTarget);

      try {
        await Supabase.instance.client.from('store_settings').upsert({
          'user_email': widget.userEmail,
          'target_omset': newTarget,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Error sync target ke Supabase: $e');
      }

      if (mounted) {
        setState(() => _targetOmset = newTarget);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Target omset tersimpan ke Supabase: Rp ${newTarget.toInt()}',
            ),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      }
      _targetController.clear();
    }
  }

  // 3. UPDATE PERMISSION HAK AKSES REALTIME KE SUPABASE
  Future<void> _togglePermission(String key, bool value) async {
    try {
      await Supabase.instance.client.from('store_settings').upsert({
        'user_email': widget.userEmail,
        key: value,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Gagal update permission ke Supabase: $e');
    }
  }*/
  Future<void> _togglePermission(String key, bool value) async {
    try {
      // Cek apakah record store_settings user ini sudah ada
      final existing = await pb
          .collection('store_settings')
          .getList(filter: 'user_email = "${widget.userEmail}"');

      if (existing.items.isNotEmpty) {
        final recordId = existing.items.first.id;
        await pb
            .collection('store_settings')
            .update(recordId, body: {key: value});
      } else {
        await pb
            .collection('store_settings')
            .create(body: {'user_email': widget.userEmail, key: value});
      }
    } catch (e) {
      debugPrint('Gagal update permission ke PocketBase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ACCUMULATE OMSET HARI INI SECARA REALTIME DARI DATA SUPABASE
    double omsetTercapaiReal = widget.ordersHariIni.fold(0.0, (sum, order) {
      if (order['status'] != 'Batal') {
        return sum + ((order['total'] as num?)?.toDouble() ?? 0.0);
      }
      return sum;
    });

    double persentase = _targetOmset > 0
        ? (omsetTercapaiReal / _targetOmset).clamp(0.0, 1.0)
        : 0.0;
    int persenInt = (persentase * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2563EB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Kelola Akun & Analitik',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.userEmail,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PANEL TRAFFIC KEUANGAN 24 JAM
            const Center(
              child: Text(
                'Geser ke kanan/kiri untuk melihat 24 jam lengkap 👈',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Pergerakan Omset (Realtime)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '24 Jam',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCandleStickItem(50, true, '00:00'),
                          _buildCandleStickItem(70, true, '04:00'),
                          _buildCandleStickItem(40, false, '08:00'),
                          _buildCandleStickItem(90, true, '12:00'),
                          _buildCandleStickItem(65, false, '16:00'),
                          _buildCandleStickItem(85, true, '20:00'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // PANEL TARGET OMSET BULANAN (REALTIME SYNC)
            Card(
              elevation: 0,
              color: const Color(0xFFF0FDF4),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.green[100]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text('🎯 ', style: TextStyle(fontSize: 12)),
                            Text(
                              'TARGET OMSET BULANAN',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$persenInt%',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pantau progres pencapaian target toko bulan ini',
                      style: TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: persentase,
                        minHeight: 10,
                        backgroundColor: Colors.green[100],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tercapai: Rp ${omsetTercapaiReal.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        Text(
                          'Target: Rp ${_targetOmset.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: TextField(
                              controller: _targetController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 11),
                              decoration: InputDecoration(
                                hintText: 'Set Target (Rp)',
                                hintStyle: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.green[200]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.green[200]!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _updateTarget,
                            child: const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SUB-KATEGORI 1: KELOLA SUB-AKUN KASIR
            _buildSubCategoryExpansionCard(
              icon: Icons.people_outline,
              title: 'Kelola Sub-Akun Kasir',
              subtitle: 'Daftar & buat sub-akun login khusus pegawai',
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daftar Kasir Aktif',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.add, size: 12),
                            label: const Text(
                              'Buat Kasir',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada kasir.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // SUB-KATEGORI 2: PENGATURAN AKSES & HAK KASIR (REALTIME TOGGLE)
            _buildSubCategoryExpansionCard(
              icon: Icons.settings_outlined,
              title: 'Pengaturan Akses & Hak Kasir',
              subtitle: 'Atur izin fitur kasir secara realtime',
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SwitchListTile(
                          dense: true,
                          value: _isManager,
                          activeColor: const Color(0xFF2563EB),
                          onChanged: (val) {
                            setState(() => _isManager = val);
                            _togglePermission('is_manager', val);
                          },
                          title: const Text(
                            '👑 Jadikan Kasir sebagai Manager',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'Akses penuh ke seluruh fitur aplikasi',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ),
                      ),
                      _buildSwitchPermissionTile(
                        '📊',
                        'Akses Menu Laporan & Report',
                        'Kasir dapat melihat rekap omset & keuangan',
                        _canViewReport,
                        (val) {
                          setState(() => _canViewReport = val);
                          _togglePermission('can_view_report', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchPermissionTile(
                        '📦',
                        'Akses Kelola Layanan & Harga',
                        'Kasir dapat menambah/menghapus paket',
                        _canManageServices,
                        (val) {
                          setState(() => _canManageServices = val);
                          _togglePermission('can_manage_services', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchPermissionTile(
                        '💸',
                        'Akses Catat Pengeluaran Toko',
                        'Kasir dapat mencatat biaya operasional',
                        _canRecordExpense,
                        (val) {
                          setState(() => _canRecordExpense = val);
                          _togglePermission('can_record_expense', val);
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchPermissionTile(
                        '❌',
                        'Akses Edit / Batalkan Order',
                        'Kasir dapat membatalkan atau mengedit order',
                        _canEditDeleteOrder,
                        (val) {
                          setState(() => _canEditDeleteOrder = val);
                          _togglePermission('can_edit_delete_order', val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandleStickItem(double height, bool isUp, String label) {
    final color = isUp ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 2, height: 8, color: color),
        Container(
          width: 10,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(width: 2, height: 8, color: color),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 7, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSubCategoryExpansionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF4F6FF),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue[100]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: const Color(0xFF2563EB), size: 18),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
          iconColor: const Color(0xFF2563EB),
          collapsedIconColor: const Color(0xFF2563EB),
          children: children,
        ),
      ),
    );
  }

  Widget _buildSwitchPermissionTile(
    String icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      dense: true,
      value: value,
      activeColor: const Color(0xFF2563EB),
      onChanged: onChanged,
      title: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 8, color: Colors.grey),
      ),
    );
  }
}

// Helper Widget Candlestick
Widget _buildCandleStickItem(double height, bool isUp, String label) {
  final color = isUp ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Container(width: 2, height: 8, color: color),
      Container(
        width: 10,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      Container(width: 2, height: 8, color: color),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 7, color: Colors.grey)),
    ],
  );
}

// Helper Widget Card Sub-Kategori dengan Panah Dropdown (ExpansionTile)
Widget _buildSubCategoryExpansionCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required List<Widget> children,
}) {
  return Card(
    elevation: 0,
    color: const Color(0xFFF4F6FF),
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.blue[100]!),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Builder(
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Icon(icon, color: const Color(0xFF2563EB), size: 18),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(fontSize: 8, color: Colors.grey),
            ),
            iconColor: const Color(0xFF2563EB),
            collapsedIconColor: const Color(0xFF2563EB),
            children: children,
          ),
        );
      },
    ),
  );
}

// Helper Widget Sub-Option di dalam Dropdown Sub-Kategori
Widget _buildSubAccountOptionTile(String title, VoidCallback onTap) {
  return Container(
    color: Colors.white,
    child: ListTile(
      dense: true,
      title: Text(
        title,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
      onTap: onTap,
    ),
  );
}

// Helper Tile Switch Izin
Widget _buildSwitchPermissionTile({
  required String icon,
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return SwitchListTile(
    dense: true,
    value: value,
    activeColor: const Color(0xFF2563EB),
    onChanged: onChanged,
    title: Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(fontSize: 8, color: Colors.grey),
    ),
  );
}
