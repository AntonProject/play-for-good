import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start supabaseEdge Group Code

class SupabaseEdgeGroup {
  static String getBaseUrl({
    String? jwt = '',
  }) =>
      'https://czjexdwjhexlyjodghwe.supabase.co/functions/v1/';
  static Map<String, String> headers = {
    'Authorization': 'Bearer [jwt]',
    'Content-Type': 'application/json',
  };
  static CreateOrgCall createOrgCall = CreateOrgCall();
  static SyncStripeAccountCall syncStripeAccountCall = SyncStripeAccountCall();
  static UpdatePayoutCall updatePayoutCall = UpdatePayoutCall();
  static GetInfoStripeCall getInfoStripeCall = GetInfoStripeCall();
  static CreatePaymentCheckoutCall createPaymentCheckoutCall =
      CreatePaymentCheckoutCall();
  static CreateReceiptCall createReceiptCall = CreateReceiptCall();
}

class CreateOrgCall {
  Future<ApiCallResponse> call({
    String? organizationId = '',
    bool? testMode = true,
    bool? sendEmail = true,
    String? jwt = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl(
      jwt: jwt,
    );

    final ffApiRequestBody = '''
{
  "organization_id": "${escapeStringForJson(organizationId)}",
  "test_mode": ${testMode},
  "send_email": ${sendEmail}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createOrg',
      apiUrl: '${baseUrl}create-connected-account',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${jwt}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SyncStripeAccountCall {
  Future<ApiCallResponse> call({
    String? organizationId = '',
    bool? testMode = true,
    String? jwt = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl(
      jwt: jwt,
    );

    final ffApiRequestBody = '''
{
  "organization_id": "${escapeStringForJson(organizationId)}",
  "test_mode": ${testMode}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'syncStripeAccount',
      apiUrl: '${baseUrl}sync-stripe-account',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${jwt}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class UpdatePayoutCall {
  Future<ApiCallResponse> call({
    String? organizationId = '',
    bool? testMode = true,
    String? jwt = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl(
      jwt: jwt,
    );

    final ffApiRequestBody = '''
{
  "organization_id": "${escapeStringForJson(organizationId)}",
  "test_mode": ${testMode}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'updatePayout',
      apiUrl: '${baseUrl}update-payout-settings',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${jwt}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class GetInfoStripeCall {
  Future<ApiCallResponse> call({
    String? organizationId = '',
    String? jwt = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl(
      jwt: jwt,
    );

    final ffApiRequestBody = '''
{
  "organization_id": "${escapeStringForJson(organizationId)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'getInfoStripe',
      apiUrl: '${baseUrl}get-stripe-account',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${jwt}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreatePaymentCheckoutCall {
  Future<ApiCallResponse> call({
    String? userId = '',
    String? gameId = '',
    String? paymentMethod = 'card',
    bool? receipt,
    bool? test = true,
    String? firstName = '',
    String? surname = '',
    String? jwt = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl(
      jwt: jwt,
    );

    final ffApiRequestBody = '''
{
  "user_id": "${escapeStringForJson(userId)}",
  "game_id": "${escapeStringForJson(gameId)}",
  "payment_method": "${escapeStringForJson(paymentMethod)}",
  "send_receipt": ${receipt},
  "test_mode": ${test},
  "first_name": "${escapeStringForJson(firstName)}",
  "surname": "${escapeStringForJson(surname)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createPaymentCheckout',
      apiUrl: '${baseUrl}create_checkout_session',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${jwt}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  String? trasactionId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.transaction_id''',
      ));
  String? url(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.checkout_url''',
      ));
  String? sessionId(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.session_id''',
      ));
}

class CreateReceiptCall {
  Future<ApiCallResponse> call({
    String? userEmail = '',
    String? startDate = '',
    String? endDate = '',
    String? jwt = '',
  }) async {
    final baseUrl = SupabaseEdgeGroup.getBaseUrl(
      jwt: jwt,
    );

    final ffApiRequestBody = '''
{
  "user_email": "${escapeStringForJson(userEmail)}",
  "start_date": "${escapeStringForJson(startDate)}",
  "end_date": "${escapeStringForJson(endDate)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createReceipt',
      apiUrl: '${baseUrl}create-receipt',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${jwt}',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End supabaseEdge Group Code

class StripeAccInfoCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'stripeAccInfo',
      apiUrl: 'https://api.stripe.com/v1/accounts/acct_1SOE24Abi2xAfYse',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer sk_test_51RiZQ5POKlqZFtw8060mlo1RKJb8553XsVerVfBmCadupslSfFiOOVswSBbsIYmt6jPeDtHJtn2tdBmO6ztxlIvA00sHBuDB9S',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class StripeAccInfoLiveCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'stripeAccInfoLive',
      apiUrl: 'https://api.stripe.com/v1/accounts/acct_1SOE24Abi2xAfYse',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer sk_test_51RiZQ5POKlqZFtw8060mlo1RKJb8553XsVerVfBmCadupslSfFiOOVswSBbsIYmt6jPeDtHJtn2tdBmO6ztxlIvA00sHBuDB9S',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class StripeAccPersonListInfoCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'stripeAccPersonListInfo',
      apiUrl:
          'https://api.stripe.com/v1/accounts/acct_1SNbICAYIjjJUdCF/persons',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer sk_test_51RiZQ5POKlqZFtw8060mlo1RKJb8553XsVerVfBmCadupslSfFiOOVswSBbsIYmt6jPeDtHJtn2tdBmO6ztxlIvA00sHBuDB9S',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class StripeAccPersonInfoCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'stripeAccPersonInfo',
      apiUrl:
          'https://api.stripe.com/v1/accounts/acct_1SNbICAYIjjJUdCF/persons/person_1SNr5EAYIjjJUdCFQfw9rnT0',
      callType: ApiCallType.GET,
      headers: {
        'Authorization':
            'Bearer sk_test_51RiZQ5POKlqZFtw8060mlo1RKJb8553XsVerVfBmCadupslSfFiOOVswSBbsIYmt6jPeDtHJtn2tdBmO6ztxlIvA00sHBuDB9S',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
