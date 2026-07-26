import 'package:drift/drift.dart';

import 'android_database_connection_stub.dart'
    if (dart.library.io) 'android_database_connection_native.dart'
    as implementation;

QueryExecutor openAndroidDatabase(String tenantId) =>
    implementation.openAndroidDatabase(tenantId);
