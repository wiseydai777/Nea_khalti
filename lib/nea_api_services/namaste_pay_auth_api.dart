import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nea_payment/models/namaste_pay_auth_model.dart';

class NamastePayException implements Exception {
  final String message;
  final int? statusCode;
  const NamastePayException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NamastePayApi {
  final String baseUrl;

  final String basicAuthBase64;

  NamastePayApi({
    this.baseUrl = 'https://testapp.namastepay.com:8811',
    this.basicAuthBase64 = 'bmRwY21vYmlsZUFwcC10ZXN0OldAdEFudE9uaW8=',
  });

  Map<String, String> get _headers => {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Basic $basicAuthBase64',
      };

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('${baseUrl.trimRight()}$path');

    final response = await http
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 30));

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw NamastePayException(
        'Server returned non-JSON response (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final bodyStatus = data['status']?.toString().toUpperCase();
    final isBodyError = bodyStatus != null && bodyStatus != 'SUCCEEDED';

    if (response.statusCode != 200 || isBodyError) {
      final msg = data['message'] ??
          data['errorMessage'] ??
          data['error'] ??
          'HTTP ${response.statusCode}';
      throw NamastePayException(msg.toString(),
          statusCode: response.statusCode);
    }

    return data;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<NamastePaySession> login(LoginRequest request) async {
    final data = await _post(
      '/mobiquitypay/v3/user/subscriberApp/login',
      request.toJson(),
    );
    return NamastePaySession.fromJson(data);
  }
}
