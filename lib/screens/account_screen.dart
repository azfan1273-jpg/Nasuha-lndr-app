import 'package:flutter/material.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2563EB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kelola Akun & Pengaturan',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PANEL TRAFFIC KEUANGAN 24 JAM (CANDLESTICK DUMMY)
            _buildSectionHeader('📊 Traffic Keuangan 24 Jam'),
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
                        Text('Pergerakan Omset (Realtime)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('24 Jam', style: TextStyle(fontSize: 9, color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Visual Simulasi Candlestick Chart
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildCandleStickItem(height: 50, isUp: true, label: '00:00'),
                          _buildCandleStickItem(height: 70, isUp: true, label: '04:00'),
                          _buildCandleStickItem(height: 40, isUp: false, label: '08:00'),
                          _buildCandleStickItem(height: 90, isUp: true, label: '12:00'),
                          _buildCandleStickItem(height: 65, isUp: false, label: '16:00'),
                          _buildCandleStickItem(height: 85, isUp: true, label: '20:00'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. PANEL TARGET OMSET BULANAN
            _buildSectionHeader('🎯 Target Omset Bulanan'),
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
                        Text('Pencapaian Bulan Ini', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Rp 15.000.000 / Rp 20.000.000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.75, // 75%
                        minHeight: 10,
                        backgroundColor: Color(0xFFEFF6FF),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Target tercapai 75%. Tetap semangat!', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. SUB-SUB AKUN (MENUNAVIGASI DETAIL)
            _buildSectionHeader('⚙️ Pengaturan Sub-Akun'),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSubAccountTile(
                    icon: Icons.person_outline,
                    title: 'Profil Toko & Kasir',
                    subtitle: 'Ubah nama toko, logo, dan profil karyawan',
                    onTap: () {
                      _openSubWindow(context, 'Profil Toko & Kasir');
                    },
                  ),
                  const Divider(height: 1),
                  _buildSubAccountTile(
                    icon: Icons.lock_outline,
                    title: 'Akses & Keamanan',
                    subtitle: 'Ganti PIN kasir dan hak akses owner',
                    onTap: () {
                      _openSubWindow(context, 'Akses & Keamanan');
                    },
                  ),
                  const Divider(height: 1),
                  _buildSubAccountTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Setting Struk & Printer',
                    subtitle: 'Atur format thermal Bluetooth/USB',
                    onTap: () {
                      _openSubWindow(context, 'Setting Struk & Printer');
                    },
                  ),
                  const Divider(height: 1),
                  _buildSubAccountTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notifikasi & WhatsApp Gateway',
                    subtitle: 'Pengaturan pesan otomatis ke pelanggan',
                    onTap: () {
                      _openSubWindow(context, 'Notifikasi & WhatsApp Gateway');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Judul Section
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  // Widget Item Candlestick
  Widget _buildCandleStickItem({required double height, required bool isUp, required String label}) {
    final color = isUp ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 2,
          height: 10,
          color: color,
        ),
        Container(
          width: 12,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          width: 2,
          height: 10,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 7, color: Colors.grey)),
      ],
    );
  }

  // Widget Item Sub-Akun Tile
  Widget _buildSubAccountTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: const Color(0xFFEFF6FF),
        child: Icon(icon, color: const Color(0xFF2563EB), size: 16),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Halaman / Jendela Baru saat Sub Menu di-klik
  void _openSubWindow(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF2563EB),
            title: Text(title, style: const TextStyle(fontSize: 14)),
          ),
          body: Center(
            child: Text('Halaman $title', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
