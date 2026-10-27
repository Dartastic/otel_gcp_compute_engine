// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_gcp_compute_engine/otel_gcp_compute_engine.dart';

/// Traces Gcp Compute Engine calls with OpenTelemetry.
///
/// `otel_gcp_compute_engine` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Gcp Compute Engine call in
/// [tracedGcpComputeEngine]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'gcp-compute-engine-example');

  // Traces a Gcp Compute Engine call.
  final gcpComputeEngineId = await tracedGcpComputeEngine<String>(
    operation: 'create',
    invoke: () async {
      // Make the Gcp Compute Engine call here, then report what it returned.
      const id = 'gcp_compute_engine_8f3a2c';
      return const GcpComputeEngineCallResult(
          value: id,
          result: GcpComputeEngineResult(
              project: 'example',
              zone: 'example',
              region: 'us-east-1',
              instanceName: 'example',
              instanceId: 'instance_8f3a2c',
              machineType: 'standard',
              status: 'succeeded',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedGcpComputeEngine create returned $gcpComputeEngineId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutGcpComputeEngineInstrumentationAsync.
  await runWithoutGcpComputeEngineInstrumentationAsync(
    () => tracedGcpComputeEngine<String>(
      operation: 'create',
      invoke: () async {
        const id = 'gcp_compute_engine_8f3a2c';
        return const GcpComputeEngineCallResult(
            value: id,
            result: GcpComputeEngineResult(
                project: 'example',
                zone: 'example',
                region: 'us-east-1',
                instanceName: 'example',
                instanceId: 'instance_8f3a2c',
                machineType: 'standard',
                status: 'succeeded',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
