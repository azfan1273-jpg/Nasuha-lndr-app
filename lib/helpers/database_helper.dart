import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static const String _keyOrders = 'local_orders_list';

  // 1. TAMBAH ORDER BARU KE STORAGE LOKAL
  Future<int> insertOrder(Map<String, dynamic> orderData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentOrders = prefs.getStringList(_keyOrders) ?? [];

    final newOrder = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'server_id': null,
      'customer_name': orderData['customer_name'] ?? 'Pelanggan',
      'total': orderData['total'] ?? 0.0,
      'status': orderData['status'] ?? 'Antrian',
      'payment_method': orderData['payment_method'] ?? 'Cash',
      'items': jsonEncode(orderData['items'] ?? []),
      'is_synced': 0,
      'created_at': DateTime.now().toIso8601String(),
    };

    currentOrders.insert(0, jsonEncode(newOrder)); // Urutan terbaru di paling atas
    await prefs.setStringList(_keyOrders, currentOrders);
    return 1;
  }

  // 2. AMBIL SEMUA ORDER UNTUK DITAMPILKAN DI KASIR
  Future<List<Map<String, dynamic>>> getLocalOrders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentOrders = prefs.getStringList(_keyOrders) ?? [];

    return currentOrders.map((itemJson) {
      final item = jsonDecode(itemJson) as Map<String, dynamic>;
      return {
        'id': item['id'],
        'server_id': item['server_id'],
        'customer': item['customer_name'],
        'total': item['total'],
        'status': item['status'],
        'is_synced': item['is_synced'] ?? 0,
        'items': jsonDecode(item['items'] as String),
        'created_at': item['created_at'],
      };
    }).toList();
  }

  // 3. AMBIL ORDER YANG BELUM DI-SYNC KE POCKETBASE
  Future<List<Map<String, dynamic>>> getUnsyncedOrders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentOrders = prefs.getStringList(_keyOrders) ?? [];

    List<Map<String, dynamic>> unsynced = [];
    for (var itemJson in currentOrders) {
      final item = jsonDecode(itemJson) as Map<String, dynamic>;
      if ((item['is_synced'] ?? 0) == 0) {
        unsynced.add(item);
      }
    }
    return unsynced;
  }

  // 4. TANDAI ORDER BAHWA SUDAH BERHASIL SYNC
  Future<void> markAsSynced(int localId, String serverId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentOrders = prefs.getStringList(_keyOrders) ?? [];

    List<String> updatedOrders = [];
    for (var itemJson in currentOrders) {
      final item = jsonDecode(itemJson) as Map<String, dynamic>;
      if (item['id'] == localId) {
        item['is_synced'] = 1;
        item['server_id'] = serverId;
      }
      updatedOrders.add(jsonEncode(item));
    }
    await prefs.setStringList(_keyOrders, updatedOrders);
  }
}
