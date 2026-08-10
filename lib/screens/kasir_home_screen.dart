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
    {'name': 'Andi Pratama', 'phone': '081234567890'},
    {'name': 'Budi Santoso', 'phone': '085678901234'},
    {'name': 'Citra Dewi', 'phone': '087890123456'},
  ];

  // --- DIALOG 1: PILIH ACTION TRANSAKSI (TAMPILAN ELEGAN) ---
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
                // Header Dialog
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Text(
                        'LNDR POS',
                        style: TextStyle(fontSize: 9, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Grid 4 Panel Action Elegan
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

  // Helper Widget Panel Elegan
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
            border: Border.all(color: accentColor.withOpacity(0.18), width: 1.2),
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
                style: const TextStyle(
                  fontSize: 8.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DIALOG 2: FORM BUAT ORDER TRANSAKSI ---
  void _showBuatOrderDialog() {
    String selectedParfum = 'Standard / Original';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 400,
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
                          const Text('Buat Order Transaksi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Pelanggan', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                SizedBox(height: 2),
                                Text('Silahkan Pilih Customer Terlebih Dahulu.', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey)),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _showPilihCustomerDialog(),
                              child: const Text('CARI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

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
                                const Text('Daftar Layanan (Keranjang)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                TextButton(
                                  onPressed: () => _showPilihLayananDialog(),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.cyan[50],
                                    foregroundColor: Colors.cyan[800],
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('+ Tambah Layanan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Belum ada layanan yang ditambahkan.', style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      const Text('Aroma Parfum', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                            style: const TextStyle(fontSize: 11, color: Colors.black),
                            items: <String>['Standard / Original', 'Lily', 'Akasia', 'Ocean Fresh']
                                .map((String value) {
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

                      const Text('Catatan Order', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      TextField(
                        maxLines: 2,
                        style: const TextStyle(fontSize: 11),
                        decoration: InputDecoration(
                          hintText: 'Contoh: Luntur, Jangan Terlalu Panas, Baju warna putih dipisah',
                          hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                          contentPadding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('TOTAL PRICE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                              Text('Rp 0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: const Text('PESAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        ],
                      )
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
  void _showPilihCustomerDialog() {
    bool isAddingNewCustomer = false;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    String searchQuery = '';

    showDialog(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          const Text('Pilih Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
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
                          hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          suffixIcon: const Icon(Icons.search, size: 16),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (filteredList.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Pelanggan tidak ditemukan.', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                            separatorBuilder: (ctx, i) => const Divider(height: 1),
                            itemBuilder: (ctx, index) {
                              final cust = filteredList[index];
                              return ListTile(
                                dense: true,
                                title: Text(cust['name']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                subtitle: Text(cust['phone']!, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                trailing: const Icon(Icons.chevron_right, size: 14, color: Colors.blue),
                                onTap: () {
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
                            backgroundColor: isAddingNewCustomer ? Colors.grey[600] : Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            setCustomerModalState(() {
                              isAddingNewCustomer = !isAddingNewCustomer;
                            });
                          },
                          child: Text(
                            isAddingNewCustomer ? 'BATAL TAMBAH' : 'TAMBAH CUSTOMER BARU',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
                                  hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: phoneController,
                                style: const TextStyle(fontSize: 11),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'No HP / WhatsApp',
                                  hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  onPressed: () {
                                    if (nameController.text.isNotEmpty) {
                                      setState(() {
                                        _customerList.insert(0, {
                                          'name': nameController.text,
                                          'phone': phoneController.text.isEmpty ? '-' : phoneController.text,
                                        });
                                      });
                                      setCustomerModalState(() {
                                        isAddingNewCustomer = false;
                                      });
                                    }
                                  },
                                  child: const Text('Simpan Customer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ]
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
  void _showPilihLayananDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    const Text('Pilih Layanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Row(
                      children: [
                        const Icon(Icons.settings, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 10),

                TextField(
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: 'Cari Layanan V2',
                    hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCategoryGroup('LAYANAN KILOAN (3)', [
                        {'name': 'setrika', 'price': 'Rp 4.000 / Kg', 'est': 'Est: 6 Hari'},
                        {'name': 'cuci lipat', 'price': 'Rp 6.000 / Kg', 'est': 'Est: 4 Hari'},
                        {'name': 'cuci kering', 'price': 'Rp 1.000.000 / Kg', 'est': 'Est: 4 Hari'},
                      ]),
                      const SizedBox(height: 10),

                      _buildCategoryGroup('LAYANAN SATUAN (2)', [
                        {'name': 'Cuci Sepatu Premium', 'price': 'Rp 25.000 / Pasang', 'est': 'Est: 2 Hari'},
                        {'name': 'Cuci Jaket Kulit', 'price': 'Rp 35.000 / Pcs', 'est': 'Est: 3 Hari'},
                      ]),
                      const SizedBox(height: 10),

                      _buildCategoryGroup('LAYANAN PCS (2)', [
                        {'name': 'Cuci Bedcover Large', 'price': 'Rp 30.000 / Pcs', 'est': 'Est: 1 Hari'},
                        {'name': 'Cuci Selimut', 'price': 'Rp 15.000 / Pcs', 'est': 'Est: 1 Hari'},
                      ]),
                      const SizedBox(height: 10),

                      _buildCategoryGroup('LAYANAN METER (1)', [
                        {'name': 'Cuci Karpet Tebal', 'price': 'Rp 15.000 / Meter', 'est': 'Est: 3 Hari'},
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
              const Icon(Icons.inventory_2_outlined, size: 14, color: Colors.amber),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                        Text(item['name']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${item['price']} • ${item['est']}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {},
                      child: const Text('+ Pilih', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  // --- DIALOG 5: KELOLA DAFTAR LAYANAN ---
  void _showKelolaLayananDialog() {
    String selectedUnit = 'Kg';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLayananState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          const Text('Kelola Daftar Layanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
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
                                Icon(Icons.add, size: 16, color: Colors.black87),
                                SizedBox(width: 4),
                                Text('Tambah Layanan Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),

                            TextField(
                              style: const TextStyle(fontSize: 11),
                              decoration: InputDecoration(
                                hintText: 'Nama Layanan (Contoh: Cuci Kiloan Express)',
                                hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                      hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: selectedUnit,
                                        isExpanded: true,
                                        style: const TextStyle(fontSize: 11, color: Colors.black),
                                        items: <String>['Kg', 'Pcs', 'Meter']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
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
                                hintText: 'Estimasi Selesai (Hari / misal: 1 atau 0.5)',
                                hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
                            ),
                            const SizedBox(height: 10),

                            const Text('Daftar Layanan Tersedia', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                                    _buildLayananItem('Cuci Kiloan Express', 'Rp 10.000 / Kg', '1 Hari'),
                                    _buildLayananItem('Cuci Kering Lipat', 'Rp 6.000 / Kg', '2 Hari'),
                                    _buildLayananItem('Setrika Saja', 'Rp 5.000 / Kg', '0.5 Hari'),
                                    _buildLayananItem('Cuci Bedcover Large', 'Rp 35.000 / Pcs', '2 Hari'),
                                    _buildLayananItem('Cuci Sepatu Premium', 'Rp 30.000 / Pcs', '3 Hari'),
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
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {},
                                child: const Text('Simpan Layanan Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      )
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

  // HELPER WIDGETS
  Widget _buildLayananItem(String title, String price, [String estimasi = '-']) {
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
                Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(price, style: const TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.bold)),
                    if (estimasi != '-') ...[
                      const SizedBox(width: 8),
                      Text('• $estimasi', style: const TextStyle(fontSize: 9, color: Colors.grey)),
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
          )
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.amber,
                            child: Icon(Icons.store, size: 16, color: Colors.white),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      settings.userRole,
                                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                settings.emailToko,
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('Refresh', style: TextStyle(fontSize: 11)),
                      )
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
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
                  selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 10),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
                    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Order'),
                    BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Report'),
                    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. BERANDA TAB
  Widget _buildBerandaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.campaign, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '📌 Promo Cuci Komplit Diskon 10% s/d Akhir Bulan!',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('📊 RINGKASAN CUCIAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Realtime', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildStatGridItem('CUCIAN AKTIF', '0', const Color(0xFFEFF6FF), const Color(0xFF2563EB), Icons.local_laundry_service),
                      const SizedBox(width: 8),
                      _buildStatGridItem('HARUS SELESAI', '0', const Color(0xFFFEF3C7), const Color(0xFFD97706), Icons.timer),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatGridItem('TERLAMBAT', '0', const Color(0xFFFEE2E2), const Color(0xFFDC2626), Icons.warning_amber_rounded),
                      const SizedBox(width: 8),
                      _buildStatGridItem('SELESAI', '0', const Color(0xFFDCFCE7), const Color(0xFF16A34A), Icons.check_circle_outline),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('💵 KEUANGAN HARI INI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Hari Ini', style: TextStyle(fontSize: 9, color: Colors.blue[600], fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Omset Hari Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      Text('Rp 0', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Pengeluaran Hari Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      Text('Rp 0', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

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
                      Text('📌 Masuk Hari Ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('0 Order', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          Container(
                            width: 320,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.inbox_outlined, size: 32, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'Belum ada orderan masuk hari ini.\nSlide ke kanan untuk melihat antrian.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. ORDER TAB
  Widget _buildOrderTab() {
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
                    Text('Daftar Order Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 2),
                    Text('Klik item untuk melihat detail & memproses', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      const Text('TOTAL PELANGGAN', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('${_customerList.length} Orang', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                )
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
                _buildSubTab('Antrian', 0, _orderFilterIndex, (idx) => setState(() => _orderFilterIndex = idx)),
                _buildSubTab('Proses', 1, _orderFilterIndex, (idx) => setState(() => _orderFilterIndex = idx)),
                _buildSubTab('Selesai', 2, _orderFilterIndex, (idx) => setState(() => _orderFilterIndex = idx)),
                _buildSubTab('Batal', 3, _orderFilterIndex, (idx) => setState(() => _orderFilterIndex = idx)),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Tidak ada orderan di status ini.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  // 3. REPORT TAB
  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('📊 LAPORAN HARI INI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                child: const Text('Today', style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _buildStatCard('OMSET', 'Rp 0', Colors.amber[50]!, Colors.amber[800]!, Icons.monetization_on),
              const SizedBox(width: 6),
              _buildStatCard('PENDAPATAN', 'Rp 0', Colors.green[50]!, Colors.green[700]!, Icons.trending_up),
              const SizedBox(width: 6),
              _buildStatCard('PENGELUARAN', 'Rp 0', Colors.red[50]!, Colors.red[700]!, Icons.shopping_bag),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildStatCard('ORDER HARI INI', '0', Colors.blue[50]!, Colors.blue[700]!, Icons.inventory_2),
              const SizedBox(width: 6),
              _buildStatCard('SELESAI HARI INI', '0', Colors.teal[50]!, Colors.teal[700]!, Icons.check_circle),
              const SizedBox(width: 6),
              _buildStatCard('BATAL HARI INI', '0', Colors.pink[50]!, Colors.pink[700]!, Icons.cancel),
            ],
          ),
          const SizedBox(height: 16),

          const Text('Laporan Keuangan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                _buildSubTab('Transaksi', 0, _reportTabFilterIndex, (idx) => setState(() => _reportTabFilterIndex = idx)),
                _buildSubTab('Laporan Keuangan', 1, _reportTabFilterIndex, (idx) => setState(() => _reportTabFilterIndex = idx)),
                _buildSubTab('Pelanggan', 2, _reportTabFilterIndex, (idx) => setState(() => _reportTabFilterIndex = idx)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _buildMenuItem(Icons.bar_chart, Colors.green, 'Semua Transaksi', 'Lihat seluruh riwayat orderan laundry'),
          _buildMenuItem(Icons.grid_view, Colors.amber[700]!, 'Transaksi per Layanan', 'Laporan orderan berdasarkan jenis layanan'),
          _buildMenuItem(Icons.hourglass_bottom, Colors.orange, 'Transaksi Belum Selesai', 'Daftar orderan aktif / antrian / proses'),
          _buildMenuItem(Icons.check_box, Colors.green, 'Transaksi Selesai', 'Daftar orderan yang sudah rampung'),
          _buildMenuItem(Icons.disabled_by_default, Colors.red, 'Transaksi Batal', 'Daftar orderan yang telah dibatalkan'),
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
          const Text('Pengaturan Toko & Kasir', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

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
                    const Text('Akun Aktif (Email)', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(settings.emailToko, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                  child: Text(settings.userRole, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),

          _buildSettingCard(
            title: 'Kelola Daftar Layanan',
            subtitle: 'Tambah atau hapus layanan & harga laundry',
            bgColor: Colors.blue[50]!,
            btnColor: const Color(0xFF2563EB),
            onPressed: () => _showKelolaLayananDialog(),
          ),
          const SizedBox(height: 10),

          _buildSettingCard(
            title: 'Kelola Aroma Parfum',
            subtitle: 'Tambah atau hapus varian aroma parfum toko',
            bgColor: Colors.green[50]!,
            btnColor: Colors.green[700]!,
            onPressed: () {},
          ),
          const SizedBox(height: 10),

          _buildSettingCard(
            title: 'Kelola Akun',
            subtitle: 'Buka analitik traffic & manajemen toko',
            bgColor: Colors.indigo[50]!,
            btnColor: Colors.indigo[700]!,
            onPressed: () {},
          ),
          const SizedBox(height: 10),

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
                Text('Database Server', style: TextStyle(fontSize: 9, color: Colors.grey)),
                SizedBox(height: 2),
                Text('Supabase Cloud Multi-Tenant Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('LOG OUT DARI AKUN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  // HELPER WIDGETS
  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatGridItem(String title, String value, Color bgColor, Color textColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
            Icon(icon, size: 18, color: textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTab(String label, int index, int selectedIndex, Function(int) onTap) {
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

  Widget _buildMenuItem(IconData icon, Color iconColor, String title, String subtitle) {
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
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        onTap: () {},
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.black54)),
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
            child: const Text('Buka', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
