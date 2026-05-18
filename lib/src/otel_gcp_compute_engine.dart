// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_gcp_compute_engine_suppression.dart';

class GcpComputeEngineResult {
  const GcpComputeEngineResult({
    this.project,
    this.zone,
    this.region,
    this.instanceName,
    this.instanceId,
    this.machineType,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? project;
  final String? zone;
  final String? region;
  final String? instanceName;
  final String? instanceId;
  final String? machineType;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class GcpComputeEngineCallResult<T> {
  const GcpComputeEngineCallResult({required this.value, this.result});
  final T value;
  final GcpComputeEngineResult? result;
}

Future<T> tracedGcpComputeEngine<T>({
  required String operation,
  required Future<GcpComputeEngineCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (gcpComputeEngineInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t =
      tracer ?? OTel.tracerProvider().getTracer('otel_gcp_compute_engine');
  final span = t.startSpan('gce $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('gcp.service', 'compute');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.project != null) {
        span.setStringAttribute('gcp.project.id', res.project!);
      }
      if (res.zone != null) {
        span.setStringAttribute('cloud.availability_zone', res.zone!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.instanceName != null) {
        span.setStringAttribute('host.name', res.instanceName!);
      }
      if (res.instanceId != null) {
        span.setStringAttribute('host.id', res.instanceId!);
      }
      if (res.machineType != null) {
        span.setStringAttribute('host.type', res.machineType!);
      }
      if (res.status != null) {
        span.setStringAttribute('gcp.gce.status', res.status!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('gce.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'gce.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
