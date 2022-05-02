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

  Future<SyncResult<TSyncable>> sync({bool fullSync = false}) async {
    if (fullSync) {
      return await controller.sync(DateTime(1900));
    }
    final lastSyncPrefs = prefs.getString(storageKey());
    late DateTime lastSync;
    if (lastSyncPrefs == null) {
      lastSync = DateTime(1900);
      await prefs.setString(storageKey(), DateTime(1900).toIso8601String());
    } else {
      lastSync = DateTime.tryParse(lastSyncPrefs)!;
    }
    final syncResult = await controller.sync(lastSync.toUtc());

    if (!syncResult.hasError) {
      await prefs.setString(storageKey(), DateTime.now().toIso8601String());
    }
    return syncResult;
  }

  String storageKey() {
    return 'entitySyncLastSync${controller.storage.getStorageName()}';
  }
}
