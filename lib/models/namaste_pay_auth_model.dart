class DeviceInfo {
  final String deviceId;
  final String model;
  final String os;
  final String appName;
  final String appVersion;
  final String isPublicDevice;
  final String providerIpAddress;

  const DeviceInfo({
    required this.deviceId,
    required this.model,
    required this.os,
    required this.appName,
    required this.appVersion,
    this.isPublicDevice = 'N',
    required this.providerIpAddress,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'model': model,
        'os': os,
        'appName': appName,
        'appVersion': appVersion,
        'isPublicDevice': isPublicDevice,
        'providerIpAddress': providerIpAddress,
      };
}

class NamastePaySession {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String subscriberId;
  final DateTime loginTime;
  final String mobileNumber;

  const NamastePaySession({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.subscriberId,
    required this.loginTime,
    required this.mobileNumber,
  });
  factory NamastePaySession.fromJson(Map<String, dynamic> json) {
    final tokenData = json['token'] as Map<String, dynamic>? ?? {};

    return NamastePaySession(
      accessToken: tokenData['access_token']?.toString() ?? '',
      refreshToken: tokenData['refresh_token']?.toString() ?? '',
      tokenType: 'Bearer',
      expiresIn: (tokenData['expires_in'] as num?)?.toInt() ?? 3600,
      subscriberId: json['userId']?.toString() ?? '',
      loginTime: json['lastLoginTime'] != null
          ? DateTime.parse(json['lastLoginTime'].toString())
          : DateTime.now(),
      mobileNumber: '',
    );
  }

  NamastePaySession copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
    String? subscriberId,
    DateTime? loginTime,
    String? mobileNumber,
  }) {
    return NamastePaySession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      subscriberId: subscriberId ?? this.subscriberId,
      loginTime: loginTime ?? this.loginTime,
      mobileNumber: mobileNumber ?? this.mobileNumber,
    );
  }

  bool get isExpired =>
      DateTime.now().isAfter(loginTime.add(Duration(seconds: expiresIn)));

  String get bearerHeader => '$tokenType $accessToken';
}

class LoginRequest {
  final String identifierValue; // phone / login ID
  final String authenticationValue; // password
  final String identifierType;
  final String language;
  final String source;
  final String bearerCode;
  final String isTokenRequired;
  final String workspaceId;
  final DeviceInfo deviceInfo;

  const LoginRequest({
    required this.identifierValue,
    required this.authenticationValue,
    this.identifierType = 'LOGINID',
    this.language = 'en',
    this.source = 'MOBILE',
    this.bearerCode = 'API',
    this.isTokenRequired = 'Y',
    this.workspaceId = 'SUBSCRIBER',
    required this.deviceInfo,
  });

  Map<String, dynamic> toJson() => {
        'language': language,
        'source': source,
        'bearerCode': bearerCode,
        'isTokenRequired': isTokenRequired,
        'workspaceId': workspaceId,
        'identifierType': identifierType,
        'identifierValue': identifierValue,
        'authenticationValue': authenticationValue,
        'deviceInfo': deviceInfo.toJson(),
      };
}
