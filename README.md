# otel_gcp_compute_engine

Dartastic OpenTelemetry bridge for GCP Compute Engine (VMs).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_gcp_compute_engine/otel_gcp_compute_engine.dart';

await tracedGcpComputeEngine<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return GcpComputeEngineCallResult(value: r, result: GcpComputeEngineResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutGcpComputeEngineInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
