/// Core payment service for EcoPay.
///
/// Orchestrates wallet, transfers, bills, links, investments, loans, and
/// bookings through the backend API client.

library payments_service;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';
import '../models/payment_method.dart';

class EcoPayService {
  final http.Client _client;

  EcoPayService(this._client);

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse(AppConfig.apiBaseUrl + path);
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('EcoPay error ${response.statusCode}: ${response.body}');
  }

  Future<Wallet> getWallet(String userId) async {
    final d = await _post('/wallet/get', {'userId': userId});
    return Wallet(
      userId: d['userId'] as String,
      availableBalancePaise: (d['availableBalancePaise'] as int?) ?? 0,
      pendingBalancePaise: (d['pendingBalancePaise'] as int?) ?? 0,
      bookedBalancePaise: (d['bookedBalancePaise'] as int?) ?? 0,
      lastSyncAt: DateTime.tryParse(d['lastSyncAt'] as String? ?? ''),
      paymentMethodIds: (d['paymentMethodIds'] as List<dynamic>?)
          ?.map((e) => e.toString()).toList() ?? [],
      isReadOnly: (d['isReadOnly'] as bool?) ?? false,
    );
  }

  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    final d = await _post('/wallet/methods', {'userId': userId});
    final items = d['methods'] as List<dynamic>? ?? [];
    return items.map(_parsePaymentMethod).toList();
  }

  PaymentMethod _parsePaymentMethod(dynamic e) {
    return PaymentMethod(
      id: e['id'] as String,
      type: _parseEnum(e['type'] as String?, PaymentMethodType.values, PaymentMethodType.wallet),
      displayName: e['displayName'] as String,
      maskedValue: e['maskedValue'] as String?,
      isDefault: (e['isDefault'] as bool?) ?? false,
      status: _parseEnum(e['status'] as String?, PaymentMethodStatus.values, PaymentMethodStatus.active),
      verifiedAt: DateTime.tryParse(e['verifiedAt'] as String? ?? ''),
      metadata: Map<String, String>.from((e['metadata'] as Map<dynamic, dynamic>?) ?? {}),
    );
  }

  Future<List<Transaction>> getTransactions(String userId, {int limit = 50}) async {
    final d = await _post('/wallet/transactions', {'userId': userId, 'limit': limit});
    final items = d['transactions'] as List<dynamic>? ?? [];
    return items.map(_parseTransaction).toList();
  }

  Transaction _parseTransaction(dynamic e) {
    return Transaction(
      id: e['id'] as String,
      type: _parseEnum(e['type'] as String?, TransactionType.values, TransactionType.bookingPayment),
      status: _parseEnum(e['status'] as String?, TransactionStatus.values, TransactionStatus.pending),
      source: _parseEnum(e['source'] as String?, TransactionSource.values, TransactionSource.marketplace),
      amountPaise: (e['amountPaise'] as int?) ?? 0,
      feePaise: e['feePaise'] as int?,
      netAmountPaise: e['netAmountPaise'] as int?,
      counterpartyId: e['counterpartyId'] as String?,
      counterpartyName: e['counterpartyName'] as String?,
      referenceId: e['referenceId'] as String?,
      metadata: Map<String, String>.from((e['metadata'] as Map<dynamic, dynamic>?) ?? {}),
      createdAt: _parseDate(e['createdAt'] as String?),
      completedAt: _parseDate(e['completedAt'] as String?),
      receiptHash: e['receiptHash'] as String?,
      description: e['description'] as String?,
    );
  }

    T _parseEnum<T extends Enum>(String? name, List<T> enumValues, T fallback) {
    if (name == null) return fallback;
    for (final v in enumValues) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  DateTime _parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return DateTime.now();
    return DateTime.tryParse(iso) ?? DateTime.now();
  }
}
