import 'package:majichrono/core/network/api_client.dart';
import 'package:majichrono/core/network/api_endpoints.dart';

/// Acces reseau brut de l'authentification.
///
/// Cette classe ne connait que des `Map` : la traduction en entites du domaine
/// est le travail du repository. La separation permet de tester le mapping sans
/// reseau, et de changer le format de reponse sans toucher au domaine.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> requestOtp(String phoneE164) =>
      _client.post<Map<String, dynamic>>(
        ApiEndpoints.otpRequest,
        body: {'phone': phoneE164},
      );

  Future<Map<String, dynamic>> verifyOtp({
    required String challengeId,
    required String code,
  }) => _client.post<Map<String, dynamic>>(
    ApiEndpoints.otpVerify,
    body: {'challengeId': challengeId, 'code': code},
  );

  Future<Map<String, dynamic>> requestEmailCode(String email) =>
      _client.post<Map<String, dynamic>>(
        ApiEndpoints.emailRequest,
        body: {'email': email},
      );

  Future<Map<String, dynamic>> verifyEmailCode({
    required String challengeId,
    required String code,
  }) => _client.post<Map<String, dynamic>>(
    ApiEndpoints.emailVerify,
    body: {'challengeId': challengeId, 'code': code},
  );

  Future<Map<String, dynamic>> signInWithPassword({
    required String email,
    required String password,
  }) => _client.post<Map<String, dynamic>>(
    ApiEndpoints.passwordSignIn,
    body: {'email': email, 'password': password},
  );

  Future<Map<String, dynamic>> signUpWithPassword({
    required String email,
    required String password,
  }) => _client.post<Map<String, dynamic>>(
    ApiEndpoints.passwordSignUp,
    body: {'email': email, 'password': password},
  );

  Future<void> linkEmail(String email) =>
      _client.post<void>(ApiEndpoints.emailLink, body: {'email': email});

  Future<Map<String, dynamic>> refresh(String refreshToken) =>
      _client.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        body: {'refreshToken': refreshToken},
      );

  Future<void> logout() => _client.post<void>(ApiEndpoints.logout);

  Future<Map<String, dynamic>> me() =>
      _client.get<Map<String, dynamic>>(ApiEndpoints.me);

  Future<Map<String, dynamic>> patchMe({String? role, String? displayName}) =>
      _client.patch<Map<String, dynamic>>(
        ApiEndpoints.me,
        body: {'role': ?role, 'displayName': ?displayName},
      );
}
