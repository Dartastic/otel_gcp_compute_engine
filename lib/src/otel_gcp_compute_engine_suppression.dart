// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'dart:async';

const _key = #dartastic_otel_libs_gcpComputeEngine_suppress;

bool gcpComputeEngineInstrumentationSuppressed() => Zone.current[_key] == true;

T runWithoutGcpComputeEngineInstrumentation<T>(T Function() body) =>
    runZoned(body, zoneValues: {_key: true});

Future<T> runWithoutGcpComputeEngineInstrumentationAsync<T>(
  Future<T> Function() body,
) => runZoned(body, zoneValues: {_key: true});
