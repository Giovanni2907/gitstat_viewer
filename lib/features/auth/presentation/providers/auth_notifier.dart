import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gitstat_viewer/core/storage/secure_storage_service.dart';
import 'auth_state.dart';
import '../../data/datasources/auth_remote_data_source.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRemoteDataSource _dataSource;
  final SecureStorageService _storageService;
  Timer? _pollingTimer;

  AuthNotifier(this._dataSource, this._storageService)
      : super(const AuthInitial()) {
    // Vérifier si un token est déjà sauvegardé au lancement
    _checkExistingToken();
  }

  /// Vérifie si l'utilisateur est déjà connecté localement
  Future<void> _checkExistingToken() async {
    final token = await _storageService.getAccessToken();
  if (token != null && token.isNotEmpty) {
    state = AuthAuthenticated(accessToken: token);
  } else {
    state = const AuthInitial();
  }
  await _storageService.saveAccessToken(token!);
state = AuthAuthenticated(accessToken: token);
  }

  /// 1. Déclenche la demande de code Device Flow
  Future<void> startDeviceFlow() async {
    state = const AuthRequestingCode();

    try {
      final response = await _dataSource.requestDeviceCode();
      state = AuthCodeReceived(deviceCode: response);

      // Démarrer immédiatement la boucle d'attente (Polling)
      _startPolling(
        deviceCode: response.deviceCode,
        intervalInSeconds: response.interval,
        expiresInSeconds: response.expiresIn,
      );
    } catch (e) {
      state = AuthError(
        message: 'Impossible de se connecter à GitHub. Vérifiez votre connexion.',
      );
    }
  }

  /// 2. Boucle temporisée (Polling) pour vérifier la validation du code
  void _startPolling({
    required String deviceCode,
    required int intervalInSeconds,
    required int expiresInSeconds,
  }) {
    // Annuler un timer existant par sécurité
    _pollingTimer?.cancel();

    final startTime = DateTime.now();
    final interval = Duration(seconds: intervalInSeconds > 0 ? intervalInSeconds : 5);

    _pollingTimer = Timer.periodic(interval, (timer) async {
      // Vérifier si le code a expiré
      final elapsed = DateTime.now().difference(startTime).inSeconds;
      if (elapsed >= expiresInSeconds) {
        timer.cancel();
        state = const AuthError(
          message: 'Le code a expiré. Veuillez relancer la connexion.',
        );
        return;
      }

      try {
        final accessToken = await _dataSource.pollForAccessToken(
          deviceCode: deviceCode,
        );

        // Si le token est enfin récupéré !
        if (accessToken != null) {
          timer.cancel();
          
          // Sauvegarder le token de façon sécurisée sur le téléphone / navigateur
          await _storageService.saveAccessToken(accessToken);

          state = AuthAuthenticated(accessToken: accessToken);
        }
      } catch (e) {
        timer.cancel();
        state = AuthError(message: e.toString());
      }
    });
  }

  /// Réinitialiser l'état ou déconnecter
  Future<void> logout() async {
    _pollingTimer?.cancel();
    await _storageService.deleteAccessToken();
    state = const AuthInitial();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}