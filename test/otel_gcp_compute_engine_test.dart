// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_gcp_compute_engine/otel_gcp_compute_engine.dart';
import 'package:test/test.dart';

void main() {
  group('otel_gcp_compute_engine', () {
    test('suppression toggles in zone', () async {
      expect(gcpComputeEngineInstrumentationSuppressed(), isFalse);
      await runWithoutGcpComputeEngineInstrumentationAsync(() async {
        expect(gcpComputeEngineInstrumentationSuppressed(), isTrue);
      });
      expect(gcpComputeEngineInstrumentationSuppressed(), isFalse);
    });

    test('GcpComputeEngineResult fields default null', () {
      const r = GcpComputeEngineResult();
      expect(r.statusCode, isNull);
    });
  });
}
