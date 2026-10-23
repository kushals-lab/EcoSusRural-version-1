import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'scheme_model.dart';

/// Lifecycle of an in-app scheme application.
enum ApplicationStatus {
  submitted,
  underReview,
  approved,
  rejected,
  actionRequired,
}

/// A single in-app application for a scheme / insurance / scholarship.
class SchemeApplication {
  final String id;
  final String schemeId;
  final String schemeName;
  final String schemeIcon;
  final String kind; // Schemes / Insurance / Scholarships
  final String type; // Government / Private
  final String applicantName;
  final String applicantEmail;

  /// Department where the file finally lands.
  final String department;

  /// Office the file sits in right now (moves on as the review progresses).
  final String currentDepartment;

  final Map<String, String> documentValues;
  final double feeInr;
  final bool feePaid;
  final DateTime submittedAt;

  /// Approximate number of working days the department declares.
  final int processingDays;

  /// Moment the department declares its result. Before that the application is
  /// "under review"; after it the stored [outcome] is shown.
  final DateTime reviewAt;

  final ApplicationStatus outcome;
  final String rejectionReason;
  final List<String> documentIssues;
  final bool canReapply;

  const SchemeApplication({
    required this.id,
    required this.schemeId,
    required this.schemeName,
    required this.schemeIcon,
    required this.kind,
    required this.type,
    required this.applicantName,
    required this.applicantEmail,
    required this.department,
    required this.currentDepartment,
    required this.documentValues,
    required this.feeInr,
    required this.feePaid,
    required this.submittedAt,
    required this.processingDays,
    required this.reviewAt,
    this.outcome = ApplicationStatus.underReview,
    this.rejectionReason = '',
    this.documentIssues = const [],
    this.canReapply = false,
  });

  /// True once the department has declared its result.
  bool get reviewComplete => !DateTime.now().isBefore(reviewAt);

  ApplicationStatus get status => reviewComplete
      ? outcome
      : (feePaid ? ApplicationStatus.underReview : ApplicationStatus.submitted);

  /// Approximate calendar date by which a result is expected.
  DateTime get expectedResultAt =>
      submittedAt.add(Duration(days: processingDays));

  /// Office the file moves through while the department verifies it.
  static String verificationOfficeFor(String kind) {
    switch (kind) {
      case 'Insurance':
        return 'Insurance Verification Cell';
      case 'Scholarships':
        return 'Institution Verification Cell';
      default:
        return 'District Programme Office (verification)';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'schemeId': schemeId,
        'schemeName': schemeName,
        'schemeIcon': schemeIcon,
        'kind': kind,
        'type': type,
        'applicantName': applicantName,
        'applicantEmail': applicantEmail,
        'department': department,
        'currentDepartment': currentDepartment,
        'documentValues': documentValues,
        'feeInr': feeInr,
        'feePaid': feePaid,
        'submittedAt': submittedAt.millisecondsSinceEpoch,
        'processingDays': processingDays,
        'reviewAt': reviewAt.millisecondsSinceEpoch,
        'outcome': outcome.name,
        'rejectionReason': rejectionReason,
        'documentIssues': documentIssues,
        'canReapply': canReapply,
      };

  static SchemeApplication fromMap(Map<String, dynamic> map) {
    return SchemeApplication(
      id: map['id'] as String? ?? '',
      schemeId: map['schemeId'] as String? ?? '',
      schemeName: map['schemeName'] as String? ?? '',
      schemeIcon: map['schemeIcon'] as String? ?? '📄',
      kind: map['kind'] as String? ?? 'Schemes',
      type: map['type'] as String? ?? 'Government',
      applicantName: map['applicantName'] as String? ?? '',
      applicantEmail: map['applicantEmail'] as String? ?? '',
      department: map['department'] as String? ?? '',
      currentDepartment: map['currentDepartment'] as String? ?? '',
      documentValues: (map['documentValues'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v.toString())),
      feeInr: (map['feeInr'] as num?)?.toDouble() ?? 0,
      feePaid: map['feePaid'] as bool? ?? false,
      submittedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['submittedAt'] as num?)?.toInt() ?? 0,
      ),
      processingDays: (map['processingDays'] as num?)?.toInt() ?? 15,
      reviewAt: DateTime.fromMillisecondsSinceEpoch(
        (map['reviewAt'] as num?)?.toInt() ?? 0,
      ),
      outcome: ApplicationStatus.values.firstWhere(
        (s) => s.name == (map['outcome'] as String? ?? ''),
        orElse: () => ApplicationStatus.underReview,
      ),
      rejectionReason: map['rejectionReason'] as String? ?? '',
      documentIssues: (map['documentIssues'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      canReapply: map['canReapply'] as bool? ?? false,
    );
  }
}

/// Result the department declares once the review window elapses.
///
/// The outcome is derived from what the applicant actually entered, so the
/// rejection reasons and document issues shown in "My Applications" always
/// explain exactly what went wrong with that submission.
class DepartmentReview {
  final ApplicationStatus status;
  final String reason;
  final List<String> documentIssues;

  const DepartmentReview({
    required this.status,
    this.reason = '',
    this.documentIssues = const [],
  });

  static DepartmentReview decide(
    SchemeModel scheme,
    Map<String, String> values,
  ) {
    final issues = <String>[];
    for (final field in scheme.documentFields) {
      if (field.optional) continue;
      final value = values[field.label]?.trim() ?? '';
      if (value.isEmpty) {
        issues.add('${field.label}: not provided');
        continue;
      }
      switch (field.label) {
        case 'Aadhaar Number':
          if (value.replaceAll(' ', '').length != 12) {
            issues.add('${field.label}: must be a 12-digit number');
          }
          break;
        case 'GSTIN':
          if (value.trim().length != 15) {
            issues.add('${field.label}: must be a 15-character GSTIN');
          }
          break;
        case 'Mobile Number':
          if (value.replaceAll(RegExp(r'[^0-9]'), '').length != 10) {
            issues.add('${field.label}: must be a 10-digit mobile number');
          }
          break;
        default:
          break;
      }
    }

    if (issues.isNotEmpty) {
      return DepartmentReview(
        status: ApplicationStatus.actionRequired,
        reason: 'Your application could not be verified because of the issues '
            'listed below. Fix them and reapply — the rest of your details were '
            'accepted.',
        documentIssues: issues,
      );
    }

    // One in four clean applications is rejected on eligibility grounds so the
    // rejection notice path stays demonstrable.
    final dice = DateTime.now().millisecondsSinceEpoch % 4;
    if (dice == 0) {
      return const DepartmentReview(
        status: ApplicationStatus.rejected,
        reason: 'The department found another active application for the same '
            'benefit under your Aadhaar, so this application was rejected. You '
            'can reapply after that application is closed.',
      );
    }

    return const DepartmentReview(status: ApplicationStatus.approved);
  }
}

/// Stores the user's scheme applications (persisted across restarts).
class SchemeApplicationsNotifier extends StateNotifier<List<SchemeApplication>> {
  SchemeApplicationsNotifier() : super(const []);

  static const String _prefsKey = 'ecosus.schemes.applications';
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;
      final list = (jsonDecode(raw) as List)
          .map((e) => SchemeApplication.fromMap(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {
      // Storage is best-effort; the in-memory list still works.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(state.map((a) => a.toMap()).toList()),
      );
    } catch (_) {
      // Storage is best-effort.
    }
  }

  /// Registers a freshly verified application (fee still unpaid) and returns
  /// the stored record.
  SchemeApplication add({
    required SchemeModel scheme,
    required String applicantName,
    required String applicantEmail,
    required Map<String, String> documentValues,
  }) {
    final now = DateTime.now();
    final application = SchemeApplication(
      id: 'APP-${now.millisecondsSinceEpoch % 1000000}',
      schemeId: scheme.id,
      schemeName: scheme.name,
      schemeIcon: scheme.icon,
      kind: scheme.kind,
      type: scheme.type,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      department: scheme.department,
      currentDepartment: SchemeApplication.verificationOfficeFor(scheme.kind),
      documentValues: documentValues,
      feeInr: scheme.applicationFeeInr,
      feePaid: false,
      submittedAt: now,
      processingDays: scheme.processingDays,
      // The department declares its result shortly after submission so the
      // notice / tracking flow is demonstrable end to end.
      reviewAt: now.add(const Duration(minutes: 1)),
    );
    state = [application, ...state];
    _persist();
    return application;
  }

  /// Marks the EcoBharatPay application fee as paid.
  void markFeePaid(String applicationId) {
    state = [
      for (final application in state)
        if (application.id == applicationId && !application.feePaid)
          SchemeApplication(
            id: application.id,
            schemeId: application.schemeId,
            schemeName: application.schemeName,
            schemeIcon: application.schemeIcon,
            kind: application.kind,
            type: application.type,
            applicantName: application.applicantName,
            applicantEmail: application.applicantEmail,
            department: application.department,
            currentDepartment: application.currentDepartment,
            documentValues: application.documentValues,
            feeInr: application.feeInr,
            feePaid: true,
            submittedAt: application.submittedAt,
            processingDays: application.processingDays,
            reviewAt: application.reviewAt,
          )
        else
          application,
    ];
    _persist();
  }

  SchemeApplication? byId(String id) {
    for (final application in state) {
      if (application.id == id) return application;
    }
    return null;
  }

  /// Returns the application with its department review resolved once the
  /// review window has passed (pure function, so it stays testable).
  static SchemeApplication resolveReview(
    SchemeApplication application,
    SchemeModel scheme,
  ) {
    if (!application.reviewComplete) return application;
    final review = DepartmentReview.decide(scheme, application.documentValues);
    return SchemeApplication(
      id: application.id,
      schemeId: application.schemeId,
      schemeName: application.schemeName,
      schemeIcon: application.schemeIcon,
      kind: application.kind,
      type: application.type,
      applicantName: application.applicantName,
      applicantEmail: application.applicantEmail,
      department: application.department,
      currentDepartment: application.department,
      documentValues: application.documentValues,
      feeInr: application.feeInr,
      feePaid: application.feePaid,
      submittedAt: application.submittedAt,
      processingDays: application.processingDays,
      reviewAt: application.reviewAt,
      outcome: review.status,
      rejectionReason: review.reason,
      documentIssues: review.documentIssues,
      canReapply: review.status != ApplicationStatus.approved,
    );
  }
}

/// Exposes the user's scheme applications.
final schemeApplicationsProvider =
    StateNotifierProvider<SchemeApplicationsNotifier, List<SchemeApplication>>(
  (ref) => SchemeApplicationsNotifier(),
);