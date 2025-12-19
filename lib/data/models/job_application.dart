import 'package:isar/isar.dart';

part 'job_application.g.dart';

/// Application Status Enum
enum ApplicationStatus {
  applied,
  interviewHR,
  interviewUser,
  technicalTest,
  offering,
  accepted,
  rejected,
  withdrawn;

  /// Get display name in Indonesian
  String get displayName {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.interviewHR:
        return 'Interview HR';
      case ApplicationStatus.interviewUser:
        return 'Interview User';
      case ApplicationStatus.technicalTest:
        return 'Technical Test';
      case ApplicationStatus.offering:
        return 'Offering';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  /// Check if this is a positive/successful status
  bool get isPositive {
    return this == ApplicationStatus.offering ||
        this == ApplicationStatus.accepted;
  }

  /// Check if this is a negative/ended status
  bool get isNegative {
    return this == ApplicationStatus.rejected ||
        this == ApplicationStatus.withdrawn;
  }

  /// Check if this is an interview status
  bool get isInterview {
    return this == ApplicationStatus.interviewHR ||
        this == ApplicationStatus.interviewUser;
  }
}

/// Job Platform Enum
enum JobPlatform {
  linkedin,
  jobstreet,
  glints,
  indeed,
  kalibrr,
  website,
  other;

  /// Get display name
  String get displayName {
    switch (this) {
      case JobPlatform.linkedin:
        return 'LinkedIn';
      case JobPlatform.jobstreet:
        return 'JobStreet';
      case JobPlatform.glints:
        return 'Glints';
      case JobPlatform.indeed:
        return 'Indeed';
      case JobPlatform.kalibrr:
        return 'Kalibrr';
      case JobPlatform.website:
        return 'Website Perusahaan';
      case JobPlatform.other:
        return 'Lainnya';
    }
  }
}

/// Job Application Isar Collection
@collection
class JobApplication {
  Id id = Isar.autoIncrement;

  /// Firebase document ID for sync reference
  @Index()
  String? firebaseDocId;

  /// Company name
  @Index()
  late String companyName;

  /// Job role/position
  late String role;

  /// Platform where applied
  @Enumerated(EnumType.name)
  late JobPlatform platform;

  /// Expected salary (optional)
  double? salary;

  /// Current status
  @Index()
  @Enumerated(EnumType.name)
  late ApplicationStatus status;

  /// When the application was created
  @Index()
  late DateTime createdAt;

  /// Last updated timestamp
  late DateTime updatedAt;

  /// Status change history
  late List<StatusLog> logs;

  /// Whether this record is synced to Firebase
  @Index()
  bool isSynced = false;

  /// Soft delete flag
  @Index()
  bool isDeleted = false;

  /// Create a new job application with initial status
  static JobApplication create({
    required String companyName,
    required String role,
    required JobPlatform platform,
    double? salary,
    String? notes,
  }) {
    final now = DateTime.now();
    return JobApplication()
      ..companyName = companyName
      ..role = role
      ..platform = platform
      ..salary = salary
      ..status = ApplicationStatus.applied
      ..createdAt = now
      ..updatedAt = now
      ..logs = [
        StatusLog()
          ..status = ApplicationStatus.applied.name
          ..timestamp = now
          ..notes = notes,
      ]
      ..isSynced = false
      ..isDeleted = false;
  }

  /// Update status and add to timeline
  void updateStatus(ApplicationStatus newStatus, {String? notes}) {
    status = newStatus;
    updatedAt = DateTime.now();
    logs.add(
      StatusLog()
        ..status = newStatus.name
        ..timestamp = updatedAt
        ..notes = notes,
    );
    isSynced = false;
  }

  /// Get logs sorted by timestamp (newest first)
  List<StatusLog> get sortedLogs {
    final sorted = List<StatusLog>.from(logs);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  /// Convert to Firebase document map
  Map<String, dynamic> toFirebaseMap() {
    return {
      'companyName': companyName,
      'role': role,
      'platform': platform.name,
      'salary': salary,
      'status': status.name,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'logs': logs
          .map(
            (log) => {
              'status': log.status,
              'timestamp': log.timestamp.toUtc().toIso8601String(),
              'notes': log.notes,
            },
          )
          .toList(),
    };
  }

  /// Create from Firebase document
  static JobApplication fromFirebaseMap(
    String docId,
    Map<String, dynamic> data,
  ) {
    final job = JobApplication()
      ..firebaseDocId = docId
      ..companyName = data['companyName'] as String
      ..role = data['role'] as String
      ..platform = JobPlatform.values.firstWhere(
        (p) => p.name == data['platform'],
        orElse: () => JobPlatform.other,
      )
      ..salary = (data['salary'] as num?)?.toDouble()
      ..status = ApplicationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ApplicationStatus.applied,
      )
      ..createdAt = DateTime.parse(data['createdAt'] as String).toLocal()
      ..updatedAt = DateTime.parse(data['updatedAt'] as String).toLocal()
      ..isSynced = true
      ..isDeleted = false;

    // Parse logs
    final logsData = data['logs'] as List<dynamic>? ?? [];
    job.logs = logsData.map((logData) {
      final logMap = logData as Map<String, dynamic>;
      return StatusLog()
        ..status = logMap['status'] as String
        ..timestamp = DateTime.parse(logMap['timestamp'] as String).toLocal()
        ..notes = logMap['notes'] as String?;
    }).toList();

    return job;
  }
}

/// Status Log - Embedded object for timeline
@embedded
class StatusLog {
  /// Status name at this point
  late String status;

  /// When this status was set
  late DateTime timestamp;

  /// Optional notes
  String? notes;

  /// Get the ApplicationStatus enum
  @ignore
  ApplicationStatus get statusEnum {
    return ApplicationStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => ApplicationStatus.applied,
    );
  }
}
