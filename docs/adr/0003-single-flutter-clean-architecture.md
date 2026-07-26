# ADR-0003: One feature-based Flutter application

Status: Accepted

Windows, Android, and Web will share one Flutter application using feature-based clean architecture, Riverpod, GoRouter, Dio, Drift, and Material 3. Platform code implements shared interfaces through conditional imports/plugins. Business rules and feature UI remain shared; separate platform applications are rejected because they would duplicate logic and drift behavior.
