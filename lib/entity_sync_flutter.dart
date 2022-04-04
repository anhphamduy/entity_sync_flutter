library entity_sync_flutter;

import 'package:entity_sync/entity_sync.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterSyncer<TSyncable extends SyncableMixin> {
  final SyncController<TSyncable> controller;
  final SharedPreferences prefs;

  const FlutterSyncer({
    Key? key,
    required this.controller,
    required this.prefs,
  });

  Future<SyncResult<TSyncable>> sync() async {
    final lastSyncPrefs = prefs.getString(storageKey());
    late DateTime lastSync;
    if (lastSyncPrefs == null) {
      lastSync = DateTime(1900);
      await prefs.setString(storageKey(), DateTime(1900).toIso8601String());
    } else {
      lastSync = DateTime.tryParse(lastSyncPrefs)!;
    }
    print(storageKey() + ' ' + lastSync.toIso8601String());
    final syncResult = await controller.sync(lastSync.toUtc());

    if (!syncResult.hasError) {
      await prefs.setString(storageKey(), DateTime.now().toIso8601String());
    }
    print(storageKey() + ' ' + prefs.getString(storageKey())!);
    return syncResult;
  }

  String storageKey() {
    return 'entitySyncLastSync${controller.storage.getStorageName()}';
  }
}
