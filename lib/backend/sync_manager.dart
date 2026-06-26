import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_db_service.dart';

class SyncManager {
  final _supabase = Supabase.instance.client;

  Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> synchronizeOfflineQueue() async {
    bool isOnline = await checkConnectivity();
    if (!isOnline) return;

    final db = await LocalDBService.instance.database;
    final List<Map<String, dynamic>> queueItems = await db.query(
      'sync_queue', 
      orderBy: 'created_at ASC'
    );

    for (var item in queueItems) {
      final int queueId = item['id'];
      final String tableName = item['table_name'];
      final Map<String, dynamic> payload = jsonDecode(item['payload']);

      try {
        if (item['action_type'] == 'INSERT') {
          await _supabase.from(tableName).insert(payload);
        } else if (item['action_type'] == 'UPDATE') {
          await _supabase.from(tableName).update(payload).eq('id', payload['id']);
        }
        
        // Remove item from local queue on successful database execution
        await db.delete('sync_queue', where: 'id = ?', whereArgs: [queueId]);
      } catch (e) {
        // If conflict occurs, log error and skip to avoid blocking the queue pipeline
        print("Reconciliation Sync Conflict encountered on ID $queueId: $e");
      }
    }
  }
}
