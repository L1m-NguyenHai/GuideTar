import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_session.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class BackendApi {
  BackendApi._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: '',
  );
  static const String _supportConversationId = String.fromEnvironment(
    'SUPPORT_CONVERSATION_ID',
    defaultValue: '',
  );

  static String get supportConversationId => _supportConversationId.trim();

  static String _normalize(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;

  static List<String> _candidateBaseUrls() {
    if (_configuredBaseUrl.trim().isNotEmpty) {
      return <String>[_normalize(_configuredBaseUrl.trim())];
    }

    final urls = <String>[];
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      urls.add('http://10.0.2.2:8000');
    }
    urls.add('http://localhost:8000');
    return urls.map(_normalize).toSet().toList(growable: false);
  }

  static Future<Map<String, dynamic>> _decodeMap(http.Response response) async {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic raw = jsonDecode(response.body);
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    throw ApiException('Backend trả về dữ liệu không hợp lệ.');
  }

  static Future<Uint8List> _decodeBytes(http.Response response) async {
    return response.bodyBytes;
  }

  static Future<List<dynamic>> _decodeList(http.Response response) async {
    if (response.body.isEmpty) {
      return <dynamic>[];
    }

    final dynamic raw = jsonDecode(response.body);
    if (raw is List) {
      return raw;
    }
    throw ApiException('Backend trả về dữ liệu không hợp lệ.');
  }

  static ApiException _buildApiError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return ApiException(detail, statusCode: response.statusCode);
        }
      }
    } catch (_) {}
    return ApiException(
      'Yêu cầu thất bại (${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  static Future<http.Response> _request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool requireAuth = false,
    bool includeOptionalAuth = false,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = AuthSession.accessToken;
    if (requireAuth) {
      if (token == null || token.isEmpty) {
        throw ApiException('Bạn cần đăng nhập để tiếp tục.');
      }
      headers['Authorization'] = 'Bearer $token';
    } else if (includeOptionalAuth && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    for (final baseUrl in _candidateBaseUrls()) {
      final uri = Uri.parse('$baseUrl$path');
      try {
        late final http.Response response;
        switch (method) {
          case 'GET':
            response = await http
                .get(uri, headers: headers)
                .timeout(const Duration(seconds: 20));
            break;
          case 'POST':
            response = await http
                .post(
                  uri,
                  headers: headers,
                  body: jsonEncode(body ?? <String, dynamic>{}),
                )
                .timeout(const Duration(seconds: 20));
            break;
          case 'PATCH':
            response = await http
                .patch(
                  uri,
                  headers: headers,
                  body: jsonEncode(body ?? <String, dynamic>{}),
                )
                .timeout(const Duration(seconds: 20));
            break;
          case 'DELETE':
            response = await http
                .delete(uri, headers: headers)
                .timeout(const Duration(seconds: 20));
            break;
          default:
            throw ApiException('Unsupported method: $method');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        if (response.statusCode == 401 && requireAuth) {
          AuthSession.clear();
        }
        throw _buildApiError(response);
      } on SocketException {
        continue;
      } on HttpException {
        continue;
      } on ApiException {
        rethrow;
      } catch (_) {
        continue;
      }
    }

    throw ApiException(
      'Không thể kết nối tới backend. Kiểm tra server rồi thử lại.',
    );
  }

  static Future<Uint8List> generateEarTrainingSound({
    required String mode,
    required String value,
    String? secondaryValue,
    int durationMs = 1400,
    int sampleRate = 44100,
    double gain = 0.22,
  }) async {
    final payload = <String, dynamic>{
      'mode': mode,
      'value': value,
      'duration_ms': durationMs,
      'sample_rate': sampleRate,
      'gain': gain,
    };
    if (secondaryValue != null && secondaryValue.trim().isNotEmpty) {
      payload['secondary_value'] = secondaryValue.trim();
    }

    for (final baseUrl in _candidateBaseUrls()) {
      final uri = Uri.parse('$baseUrl/api/ear-training/sound');
      try {
        final response = await http
            .post(
              uri,
              headers: <String, String>{'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return _decodeBytes(response);
        }

        throw _buildApiError(response);
      } on SocketException {
        continue;
      } on HttpException {
        continue;
      } on ApiException {
        rethrow;
      } catch (_) {
        continue;
      }
    }

    throw ApiException('Không thể kết nối tới backend. Kiểm tra server rồi thử lại.');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _request(
      method: 'POST',
      path: '/auth/login',
      body: <String, dynamic>{'email': email, 'password': password},
    );
    final payload = await _decodeMap(response);
    AuthSession.setTokens(
      access: (payload['access_token'] ?? '').toString(),
      refresh: (payload['refresh_token'] ?? '').toString(),
      userPayload: Map<String, dynamic>.from(payload['user'] as Map),
    );
    return payload;
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _request(
      method: 'POST',
      path: '/auth/register',
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'username': username,
      },
    );
    final payload = await _decodeMap(response);
    AuthSession.setTokens(
      access: (payload['access_token'] ?? '').toString(),
      refresh: (payload['refresh_token'] ?? '').toString(),
      userPayload: Map<String, dynamic>.from(payload['user'] as Map),
    );
    return payload;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final response = await _request(
      method: 'GET',
      path: '/users/me',
      requireAuth: true,
    );
    final payload = await _decodeMap(response);
    AuthSession.user = Map<String, dynamic>.from(payload);
    return payload;
  }

  static Future<Map<String, dynamic>> updateMe({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (displayName != null && displayName.trim().isNotEmpty) {
      body['display_name'] = displayName.trim();
    }
    if (bio != null) {
      body['bio'] = bio.trim();
    }
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      body['avatar_url'] = avatarUrl.trim();
    }

    final response = await _request(
      method: 'PATCH',
      path: '/users/me',
      body: body,
      requireAuth: true,
    );
    final payload = await _decodeMap(response);
    AuthSession.user = Map<String, dynamic>.from(payload);
    return payload;
  }

  static Future<List<Map<String, dynamic>>> getFavoriteSongs() async {
    final response = await _request(
      method: 'GET',
      path: '/favorites/songs',
      requireAuth: true,
    );
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> getFavoriteLessons() async {
    final response = await _request(
      method: 'GET',
      path: '/favorites/lessons',
      requireAuth: true,
    );
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> getRecentLessons() async {
    final response = await _request(
      method: 'GET',
      path: '/favorites/recent-lessons',
      requireAuth: true,
    );
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> getCatalogRecommendedSongs({
    int limit = 10,
  }) async {
    final response = await _request(
      method: 'GET',
      path: '/catalog/recommended?limit=$limit',
    );
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> getCatalogArtists({
    int limit = 20,
  }) async {
    final response = await _request(
      method: 'GET',
      path: '/catalog/artists?limit=$limit',
    );
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> getArtistDetail(String artistName) async {
    final encodedName = Uri.encodeComponent(artistName.trim());
    final response = await _request(
      method: 'GET',
      path: '/artists/$encodedName',
      includeOptionalAuth: true,
    );
    return _decodeMap(response);
  }

  static Future<void> followArtist(String artistName) async {
    final encodedName = Uri.encodeComponent(artistName.trim());
    await _request(
      method: 'POST',
      path: '/artists/$encodedName/follow',
      requireAuth: true,
    );
  }

  static Future<void> unfollowArtist(String artistName) async {
    final encodedName = Uri.encodeComponent(artistName.trim());
    await _request(
      method: 'DELETE',
      path: '/artists/$encodedName/follow',
      requireAuth: true,
    );
  }

  static Future<Map<String, dynamic>> getWeeklyAnalytics() async {
    final response = await _request(
      method: 'GET',
      path: '/analytics/weekly',
      requireAuth: true,
    );
    return _decodeMap(response);
  }

  static Future<List<Map<String, dynamic>>> getSupportCategories() async {
    final response = await _request(method: 'GET', path: '/support/categories');
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> getSupportFaqs({
    String? categoryCode,
  }) async {
    final query = (categoryCode != null && categoryCode.trim().isNotEmpty)
        ? '?category_code=${Uri.encodeComponent(categoryCode)}'
        : '';
    final response = await _request(method: 'GET', path: '/support/faqs$query');
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<List<Map<String, dynamic>>> getSupportMessages(
    String conversationId,
  ) async {
    final response = await _request(
      method: 'GET',
      path: '/support/conversations/$conversationId/messages',
      requireAuth: true,
    );
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> sendSupportMessage({
    required String conversationId,
    required String messageText,
  }) async {
    final response = await _request(
      method: 'POST',
      path: '/support/conversations/$conversationId/messages',
      body: <String, dynamic>{'message_text': messageText},
      requireAuth: true,
    );
    return _decodeMap(response);
  }

  static Future<List<Map<String, dynamic>>> getBillingPlans() async {
    final response = await _request(method: 'GET', path: '/billing/plans');
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>?> getBillingSubscription() async {
    final response = await _request(
      method: 'GET',
      path: '/billing/subscription',
      requireAuth: true,
    );
    if (response.body.isEmpty || response.body.trim() == 'null') {
      return null;
    }
    return _decodeMap(response);
  }

  static Future<List<Map<String, dynamic>>> getBillingTransactions() async {
    final response = await _request(
      method: 'GET',
      path: '/billing/transactions',
      requireAuth: true,
    );
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> cancelSubscription() async {
    final response = await _request(
      method: 'POST',
      path: '/billing/subscription/cancel',
      requireAuth: true,
      body: <String, dynamic>{},
    );
    return _decodeMap(response);
  }

  static Future<List<Map<String, dynamic>>> getAnalyzeHistory() async {
    final response = await _request(
      method: 'GET',
      path: '/api/analyze/history',
      requireAuth: true,
    );
    final payload = await _decodeList(response);
    return payload
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> getAnalyzeHistoryDetail(String analysisId) async {
    final response = await _request(
      method: 'GET',
      path: '/api/analyze/history/$analysisId',
      requireAuth: true,
    );
    return _decodeMap(response);
  }

  static Future<Map<String, dynamic>> pay({
    required double amount,
    required String currency,
    required String methodType,
    String? subscriptionId,
  }) async {
    final response = await _request(
      method: 'POST',
      path: '/billing/pay',
      requireAuth: true,
      body: <String, dynamic>{
        'amount': amount,
        'currency': currency,
        'method_type': methodType,
        'subscription_id': subscriptionId,
      },
    );
    return _decodeMap(response);
  }
}
