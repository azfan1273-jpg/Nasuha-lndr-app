import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../main.dart';

class SyncService {
  static final SyncService instance = SyncService._init();
  SyncService._init();

  bool _isSyncing = false;

  Future<void> syncPendingOrders({BuildContext? context}) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final unsyncedOrders = await DatabaseHelper.instance.getUnsyncedOrders();
      if (unsyncedOrders.isEmpty) {
        _isSyncing = false;
        return;
      }

      for (var order in unsyncedOrders) {
        try {
          final body = {
            'customer_name': order['customer'],
            'total': order['total'],
            'status': order['status'],
            'payment_method': 'Cash',
            'items': order['items'],
          };

          final record = await pb.collection('orders').create(body: body);
          await DatabaseHelper.instance.markAsSynced(order['id'], record.id);
        } catch (e) {
          debugPrint('Gagal sync item: $e');
          break;
        }
      }
    } catch (e) {
      debugPrint('Error pada SyncService: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
