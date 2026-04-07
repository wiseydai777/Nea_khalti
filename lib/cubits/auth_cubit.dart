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
    }
  }

  void logout() => emit(AuthLoggedOut());

  void clearError() {
    if (state is AuthError) emit(AuthInitial());
  }
}
