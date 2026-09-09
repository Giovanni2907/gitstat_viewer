import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provider d'instance FlutterSecureStorage avec options multi-plateforme
final secureStorageProvider = Provider<SecureStorageService>((ref) {
   const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    webOptions: WebOptions(
      dbName: 'GitStatViewerStorage',
      publicKey: 'GitStatViewerPublicKey',
    ),
  );
  return SecureStorageService(storage);
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'github_access_token';

  SecureStorageService(this._storage);

  /// Enregistrer le token d'accès GitHub
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Récupérer le token d'accès GitHub
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Supprimer le token (Déconnexion)
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Vérifier si l'utilisateur possède déjà un token
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}