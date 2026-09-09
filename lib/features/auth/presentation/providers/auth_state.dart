import '../../data/models/device_code_response.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState{
  const AuthInitial();
}

class AuthRequestingCode extends AuthState{
  const AuthRequestingCode();
}

class AuthCodeReceived extends AuthState{
  final DeviceCodeResponse deviceCode;
  const AuthCodeReceived({required this.deviceCode});
}

class AuthAuthenticated extends AuthState{
  final String accessToken;
  const AuthAuthenticated({required this.accessToken});
}

class AuthError extends AuthState{
  final String message;
  const AuthError({required this.message});
}

