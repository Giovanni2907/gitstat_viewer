//Modèle de réponse de device code
class DeviceCodeResponse {
  final String deviceCode;
  final String userCode;
  final String verificationUri;
  final int expiresIn;
  final int interval;

  DeviceCodeResponse({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.expiresIn,
    required this.interval,
  });

  factory DeviceCodeResponse.fromJson(Map<String, dynamic> json) {
    return DeviceCodeResponse(
      deviceCode: json['device_code'],
      userCode: json['user_code'],
      verificationUri: json['verification_uri'],
      expiresIn: json['expires_in'],
      interval: json['interval'],
    );
  }
}