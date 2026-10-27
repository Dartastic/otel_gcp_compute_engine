// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_gcp_compute_engine_suppression.dart';

class GcpComputeEngineResult {
  /// Creates a result.
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

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class GcpComputeEngineCallResult<T> {
  /// Creates a call result.
  const GcpComputeEngineCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final GcpComputeEngineResult? result;
}

Future<T> tracedGcpComputeEngine<T>({
  required String operation,
  required Future<GcpComputeEngineCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (gcpComputeEngineInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t =
      tracer ?? OTelAPI.tracerProvider().getTracer('otel_gcp_compute_engine');
  final span = t.startSpan('gce $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('gcp.service', 'compute')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.project != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gcp.project.id', res.project!)]));
      }
      if (res.zone != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.availability_zone', res.zone!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.instanceName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('host.name', res.instanceName!)]));
      }
      if (res.instanceId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('host.id', res.instanceId!)]));
      }
      if (res.machineType != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('host.type', res.machineType!)]));
      }
      if (res.status != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gcp.gce.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gce.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'gce.error',
          )
        ]));
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
