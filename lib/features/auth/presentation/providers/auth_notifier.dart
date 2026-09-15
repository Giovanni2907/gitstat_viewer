import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../../../core/storage/secure_storage_service.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _storageService;
  Timer? _pollingTimer;
  bool _isPolling = false;

  AuthNotifier(this._remoteDataSource, this._storageService)
      : super(const AuthInitial()) {
    checkExistingToken();
  }

  Future<void> checkExistingToken() async {
    final token = await _storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      state = AuthAuthenticated(accessToken: token);
    } else {
      state = const AuthInitial();
    }
  }

  Future<void> startDeviceFlow() async {
    state = const AuthRequestingCode();
    try {
      final deviceCodeResponse = await _remoteDataSource.requestDeviceCode();
      state = AuthCodeReceived(deviceCode: deviceCodeResponse);

      _startPolling(
        deviceCode: deviceCodeResponse.deviceCode,
        intervalInSeconds: deviceCodeResponse.interval,
        expiresInSeconds: deviceCodeResponse.expiresIn,
      );
    } catch (e) {
      state = AuthError(message: 'Échec de la demande de code : ${e.toString()}');
    }
  }

  void _startPolling({
  required String deviceCode,
  required int intervalInSeconds,
  required int expiresInSeconds,
}) {
  _pollingTimer?.cancel();
  _isPolling = false;
  final startTime = DateTime.now();
  int currentInterval = intervalInSeconds < 5 ? 5 : intervalInSeconds;

  void tick(Timer timer) async {
    if (_isPolling) return;

    final elapsed = DateTime.now().difference(startTime).inSeconds;
    if (elapsed >= expiresInSeconds) {
      timer.cancel();
      state = const AuthError(message: 'Le code a expiré. Veuillez réessayer.');
      return;
    }

    try {
      _isPolling = true;
      final result = await _remoteDataSource.pollForAccessToken(deviceCode);
      _isPolling = false;

      if (result.accessToken != null) {
        timer.cancel();
        await _storageService.saveAccessToken(result.accessToken!);
        state = AuthAuthenticated(accessToken: result.accessToken!);
        return;
      }

      if (result.newInterval != null && result.newInterval! > currentInterval) {
        // GitHub demande de ralentir : on recrée le timer avec le nouvel intervalle
        currentInterval = result.newInterval!;
        timer.cancel();
        _pollingTimer = Timer.periodic(Duration(seconds: currentInterval), tick);
      }
      // sinon (authorization_pending) : on ne fait rien, le timer continue tel quel
    } catch (e) {
      _isPolling = false;
      timer.cancel();
      state = AuthError(message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  _pollingTimer = Timer.periodic(Duration(seconds: currentInterval), tick);
}

  Future<void> logout() async {
    _pollingTimer?.cancel();
    _isPolling = false;
    await _storageService.deleteAccessToken();
    state = const AuthInitial();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}