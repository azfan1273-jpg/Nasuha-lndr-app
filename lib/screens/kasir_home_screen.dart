import 'package:flutter/material.dart';

class KasirHomeScreen extends StatefulWidget {
  const KasirHomeScreen({super.key});

  @override
  State<KasirHomeScreen> createState() => _KasirHomeScreenState();
}

class _KasirHomeScreenState extends State<KasirHomeScreen> {
  int _currentIndex = 2; // Default aktif di tab Report

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Center(
        child: Container(
          width: 450,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            children: [
              // 1. Header Biru Ala LNDR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFF2563EB),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.store, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'NASUHA LAUNDRY',
                                    style: TextStyle(
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
                                    child: const Text(
                                      'OWNER',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'superadmin.lndr@gmail.com',
                                style: TextStyle(color: Colors.white70, fontSize: 10),
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

              // 2. Body Dashboard
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul & Badge Today
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '📅 LAPORAN HARI INI',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Today',
                              style: TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Grid Statistik Ringkasan (Baris 1)
                      Row(
                        children: [
                          _buildStatCard('OMSET', 'Rp 0', Colors.amber[50]!, Colors.amber[800]!, Icons.monetization_on),
                          const SizedBox(width: 8),
                          _buildStatCard('PENDAPATAN', 'Rp 0', Colors.green[50]!, Colors.green[700]!, Icons.trending_up),
                          const SizedBox(width: 8),
                          _buildStatCard('PENGELUARAN', 'Rp 0', Colors.red[50]!, Colors.red[700]!, Icons.shopping_bag),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Grid Statistik Ringkasan (Baris 2)
                      Row(
                        children: [
                          _buildStatCard('ORDER HARI INI', '0', Colors.blue[50]!, Colors.blue[700]!, Icons.inventory_2),
                          const SizedBox(width: 8),
                          _buildStatCard('SELESAI HARI INI', '0', Colors.teal[50]!, Colors.teal[700]!, Icons.check_circle),
                          const SizedBox(width: 8),
                          _buildStatCard('BATAL HARI INI', '0', Colors.pink[50]!, Colors.pink[700]!, Icons.cancel),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section Laporan Keuangan
                      const Text(
                        'Laporan Keuangan',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      // Tab Filter
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _buildFilterTab('Transaksi', true),
                            _buildFilterTab('Laporan Keuangan', false),
                            _buildFilterTab('Pelanggan', false),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // List Menu Laporan
                      _buildMenuItem(Icons.bar_chart, Colors.green, 'Semua Transaksi', 'Lihat seluruh riwayat orderan laundry'),
                      _buildMenuItem(Icons.grid_view, Colors.amber[700]!, 'Transaksi per Layanan', 'Laporan orderan berdasarkan jenis layanan'),
                      _buildMenuItem(Icons.hourglass_bottom, Colors.orange, 'Transaksi Belum Selesai', 'Daftar orderan aktif / antrian / proses'),
                      _buildMenuItem(Icons.check_box, Colors.green, 'Transaksi Selesai', 'Daftar orderan yang sudah rampung'),
                      _buildMenuItem(Icons.disabled_by_default, Colors.red, 'Transaksi Batal', 'Daftar orderan yang telah dibatalkan'),
                      
                      const SizedBox(height: 16),
                      
                      // Tombol Menu Transaksi Biru
                      SizedBox(
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
                          onPressed: () {},
                          child: const Text(
                            'MENU TRANSAKSI',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // 3. Bottom Navigation Bar
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isActive) {
    return Expanded(
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
        leading: Icon(icon, color: iconColor, size: 24),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
