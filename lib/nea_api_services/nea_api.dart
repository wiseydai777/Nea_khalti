import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nea_payment/models/nea_api_models.dart';
import 'package:uuid/uuid.dart';

class NeaApiException implements Exception {
  final String message;
  final int? statusCode;
  const NeaApiException(this.message, {this.statusCode});

  @override
  String toString() => 'NeaApiException: $message';
}

class NeaApi {
  final String baseUrl;
  final String token;
  static const _uuid = Uuid();

  NeaApi({required this.baseUrl, required this.token});

  String get _ref => _uuid.v4();

  // Token goes in the request body, not the Authorization header.
  // Confirmed by curl testing: Khalti service endpoints read "token" from body.
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  /// Merges the token into every request body automatically.
  Map<String, dynamic> _withToken(Map<String, dynamic> body) => {
        'token': token,
        ...body,
      };

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$base$path');

    debugPrint('POST $uri');
    debugPrint('Body: ${jsonEncode(_withToken(body))}');

    final http.Response response;
    try {
      response = await http
          .post(uri, headers: _headers, body: jsonEncode(_withToken(body)))
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const NeaApiException('Request timed out. Please try again.');
    } catch (e) {
      throw NeaApiException('Network error: ${e.runtimeType}');
    }

    debugPrint('Response ${response.statusCode}: ${response.body}');

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw NeaApiException(
        'Invalid response from server (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode != 200 || data['status'] == false) {
      // Try to surface the most descriptive error message available.
      final details = data['details'];
      String? detailMsg;
      if (details is Map && details.isNotEmpty) {
        detailMsg = details.values.first is List
            ? (details.values.first as List).first.toString()
            : details.values.first.toString();
      }
      final msg = detailMsg ??
          data['message'] ??
          data['detail'] ??
          data['error'] ??
          'HTTP ${response.statusCode}';
      throw NeaApiException(msg.toString(), statusCode: response.statusCode);
    }

    return data;
  }

  // ── 1. Get Counters ───────────────────────────────────────────────────────

  Future<List<NeatCounter>> getCounters() async {
    final data = await _post('/api/servicegroup/counters/nea-v2/', {});
    final list = data['counters'] as List<dynamic>? ?? [];
    return list
        .map((e) => NeatCounter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── 2. Get New Consumer ID (V2 migration) ─────────────────────────────────

  Future<String> getNewConsumerID({
    required String scNo,
    required String oldConsumerId,
    required String orgName,
  }) async {
    final data = await _post('/api/servicegroup/user-info/nea-v2/', {
      'reference': _ref,
      'sc_no': scNo,
      'old_consumer_id': oldConsumerId,
      'org_name': orgName,
    });
    return data['consumer_no'] as String;
  }

  // ── 3a. Fetch bills — V2 ─────────────────────────────────────────────────

  Future<BillDetailV2> getBillDetailsV2({
    required String consumerNo,
  }) async {
    final data = await _post('/api/servicegroup/details/nea-v2/', {
      'reference': _ref,
      'request_no': consumerNo,
      'confirm_type': 'Energy Charge',
      'confirm_id_type': 'Consumer Number',
    });
    return BillDetailV2.fromJson(data);
  }

  // ── 3b. Fetch bills — V1 ─────────────────────────────────────────────────

  Future<BillDetailV1> getBillDetailsV1({
    required String scNo,
    required String consumerId,
    required String officeCode,
  }) async {
    final data = await _post('/api/servicegroup/details/nea/', {
      'reference': _ref,
      'sc_no': scNo,
      'consumer_id': consumerId,
      'office_code': officeCode,
    });
    return BillDetailV1.fromJson(data);
  }

  // ── 4. Service charge (V1 only) ───────────────────────────────────────────

  Future<ServiceCharge> getServiceCharge({
    required double amount,
    required int sessionId,
  }) async {
    final data = await _post('/api/servicegroup/servicecharge/nea/', {
      'amount': amount.toStringAsFixed(2),
      'session_id': sessionId.toString(),
    });
    return ServiceCharge.fromJson(data);
  }

  // ── 5a. Make payment — V2 ────────────────────────────────────────────────

  Future<PaymentResult> makePaymentV2({
    required int sessionId,
    required double amount,
    List<String>? billIds,
  }) async {
    final body = <String, dynamic>{
      'reference': _ref,
      'session_id': sessionId.toString(),
      'amount': amount.toStringAsFixed(2),
    };
    if (billIds != null && billIds.isNotEmpty) {
      body['bill_id'] = billIds.join(',');
    }
    final data = await _post('/api/servicegroup/commit/nea-v2/', body);
    return PaymentResult.fromJson(data);
  }

  // ── 5b. Make payment — V1 ────────────────────────────────────────────────

  Future<PaymentResult> makePaymentV1({
    required int sessionId,
    required double amount,
  }) async {
    final data = await _post('/api/servicegroup/commit/nea/', {
      'reference': _ref,
      'session_id': sessionId.toString(),
      'amount': amount.toStringAsFixed(2),
    });
    return PaymentResult.fromJson(data);
  }
}
