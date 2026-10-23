/// Customer verification result object returned by the stored procedure
/// [verifyCustomer] on the backend.
class StoredProcedureResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const StoredProcedureResult({
    required this.success,
    required this.message,
    this.data,
  });

  factory StoredProcedureResult.success(String message,
      [Map<String, dynamic>? data]) {
    return StoredProcedureResult(
      success: true,
      message: message,
      data: data,
    );
  }

  factory StoredProcedureResult.failure(String message) {
    return StoredProcedureResult(
      success: false,
      message: message,
    );
  }

  StoredProcedureResult copyWith({
    bool? success,
    String? message,
    Map<String, dynamic>? data,
  }) {
    return StoredProcedureResult(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
