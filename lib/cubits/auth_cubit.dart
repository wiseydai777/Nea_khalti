import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nea_payment/models/namaste_pay_auth_model.dart';
import 'package:nea_payment/nea_api_services/namaste_pay_auth_api.dart';

// ── State ─────────────────────────────────────────────────────────────────────

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final NamastePaySession session;
  AuthAuthenticated(this.session);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthLoggedOut extends AuthState {}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  final String baseUrl;
  final String basicAuthBase64;

  /// Set to true to skip the real API and use a mock session.
  /// Flip to false once testapp.namastepay.com:8811 is reachable again.
  static const bool _mockMode = true;

  AuthCubit({
    this.baseUrl = 'https://testapp.namastepay.com:8811',
    this.basicAuthBase64 = 'bmRwY21vYmlsZUFwcC10ZXN0OldAdEFudE9uaW8=',
  }) : super(AuthInitial());

  NamastePaySession? get session =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).session : null;

  bool get isLoggedIn =>
      state is AuthAuthenticated &&
      !(state as AuthAuthenticated).session.isExpired;

  Future<void> login({
    required String mobileNumber,
    required String password,
    required String deviceId,
    String appName = 'NEA Payment App',
    String appVersion = '1.0.0',
    String os = 'android',
    String model = 'flutter_device',
    String providerIp = '0.0.0.0',
  }) async {
    emit(AuthLoading());

    if (_mockMode) {
      await Future.delayed(const Duration(milliseconds: 600));

      if (mobileNumber.isEmpty || password.isEmpty) {
        emit(AuthError('Mobile number and password are required.'));
        return;
      }

      final mockSession = NamastePaySession(
        accessToken: 'mock_access_token_dev_only',
        refreshToken: 'mock_refresh_token_dev_only',
        tokenType: 'Bearer',
        expiresIn: 3600,
        subscriberId: 'mock_subscriber_001',
        loginTime: DateTime.now(),
        mobileNumber: mobileNumber,
      );
      emit(AuthAuthenticated(mockSession));
      return;
    }

    // ── Real API path (used when _mockMode = false) ────────────────────────
    try {
      final api = NamastePayApi(
        baseUrl: baseUrl,
        basicAuthBase64: basicAuthBase64,
      );
      final session = await api.login(LoginRequest(
        identifierValue: mobileNumber,
        authenticationValue: password,
        deviceInfo: DeviceInfo(
          deviceId: deviceId,
          model: model,
          os: os,
          appName: appName,
          appVersion: appVersion,
          providerIpAddress: providerIp,
        ),
      ));
      emit(AuthAuthenticated(session));
    } on NamastePayException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      // Catch-all for unexpected errors (timeout, etc.) not wrapped by the API layer.
      emit(AuthError('Unexpected error: ${e.runtimeType}. '
          'Check server connectivity.'));
    }
  }

  void logout() => emit(AuthLoggedOut());

  void clearError() {
    if (state is AuthError) emit(AuthInitial());
  }
}
