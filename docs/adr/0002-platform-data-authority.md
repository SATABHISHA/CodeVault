# ADR-0002: Platform-specific data authority

Status: Accepted

Windows SQLite is authoritative for its offline installation and has no cloud runtime dependency. Laravel/MySQL is authoritative for Android and Web; their Drift stores are disposable working copies plus pending-operation queues. This deliberately prevents ambiguous multi-master behavior. Cloud and local datasets are not silently treated as interchangeable.
