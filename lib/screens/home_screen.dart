import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;

  int _statAktif = 0;
  int _statHarusSelesai = 0;
  int _statTerlambat = 0;
  int _statSelesai = 0;
  double _statOmsetHariIni = 0;
  List<Map<String, dynamic>> _orderMasukHariIni = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final res = await SupabaseService.client
          .from('transaksi')
          .select('*, pelanggan(nama)')
          .order('id', ascending: false);

      final List data = res as List;
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      int aktif = 0, harus = 0, terlambat = 0, selesai = 0;
      double omset = 0;
      List<Map<String, dynamic>> listMasuk = [];

      for (var item in data) {
        final st = (item['status_laundry'] ?? item['status'] ?? 'Diterima').toString().trim();
        final createdAt = (item['created_at'] ?? '').toString();

        if (st != 'Selesai' && st != 'Batal') aktif++;
        if (st == 'Harus Selesai') harus++;
        if (st == 'Terlambat') terlambat++;
        if (st == 'Selesai') selesai++;

        if (createdAt.startsWith(todayStr)) {
          if (st != 'Batal') {
            omset += (item['total_harga'] ?? 0).toDouble();
          }
          listMasuk.add(Map<String, dynamic>.from(item));
        }
      }

      setState(() {
        _statAktif = aktif;
        _statHarusSelesai = harus;
        _statTerlambat = terlambat;
        _statSelesai = selesai;
        _statOmsetHariIni = omset;
        _orderMasukHariIni = listMasuk;
      });
    } catch (e) {
      debugPrint('Error load dashboard: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Center(
        child: Container(
          width: 450,
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
                            child: Icon(Icons.local_laundry_service, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('LNDR POS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('OWNER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const Text('owner@lndr.com', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          )
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                        onPressed: _loadDashboardData,
                      )
                    ],
                  ),
                ),
              ),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.campaign, color: Colors.amber, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Promo Cuci Komplit Diskon 10% s/d Akhir Bulan!',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            const Text('📊 RINGKASAN CUCIAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatBox('Cucian Aktif', '$_statAktif', Colors.blue.shade50, Colors.blue),
                                const SizedBox(width: 6),
                                _buildStatBox('Harus Selesai', '$_statHarusSelesai', Colors.amber.shade50, Colors.amber.shade800),
                                const SizedBox(width: 6),
                                _buildStatBox('Terlambat', '$_statTerlambat', Colors.red.shade50, Colors.red),
                                const SizedBox(width: 6),
                                _buildStatBox('Selesai', '$_statSelesai', Colors.green.shade50, Colors.green),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('💵 Keuangan Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text('Rp ${_statOmsetHariIni.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('📌 Masuk Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text('${_orderMasukHariIni.length} Order', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_orderMasukHariIni.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: Text('Belum ada orderan masuk hari ini.', style: TextStyle(fontSize: 11, color: Colors.grey))),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _orderMasukHariIni.length,
                                itemBuilder: (context, index) {
                                  final item = _orderMasukHariIni[index];
                                  final namaPel = item['pelanggan']?['nama'] ?? 'Pelanggan Umum';
                                  final total = item['total_harga'] ?? 0;
                                  final status = item['status_laundry'] ?? item['status'] ?? 'Diterima';

                                  return Card(
                                    elevation: 0,
                                    color: Colors.grey.shade50,
                                    margin: const EdgeInsets.only(bottom: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                                    child: ListTile(
                                      dense: true,
                                      title: Text('Nota #${item['id']} - $namaPel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                      subtitle: Text('Rp $total', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                        child: Text(status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                      ),
                                    ),
                                  );
                                },
                              )
                          ],
                        ),
                      ),
              ),

              BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                selectedItemColor: const Color(0xFF2563EB),
                unselectedItemColor: Colors.grey,
                selectedFontSize: 10,
                unselectedFontSize: 10,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
                  BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Order'),
                  BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
                  BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }
}
