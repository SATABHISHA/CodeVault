import 'package:drift/drift.dart';

import 'web_database_connection_stub.dart'
    if (dart.library.js_interop) 'web_database_connection_browser.dart'
    as implementation;

QueryExecutor openWebDatabase(String tenantId) =>
    implementation.openWebDatabase(tenantId);
