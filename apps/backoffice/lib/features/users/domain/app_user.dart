import 'user_role.dart';

enum UserStatus { active, invited, disabled }

extension UserStatusX on UserStatus {
  String get wire => name;
}

/// Perfil de usuario (Firestore `users/{uid}`).
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.phone,
    this.documentType,
    this.documentNumber,
    required this.tenantId,
    required this.role,
    this.brandIds = const <String>[],
    this.storeIds = const <String>[],
    this.status = UserStatus.active,
    this.locale = 'es',
    this.timezone = 'America/Lima',
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.createdBy,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? documentType;
  final String? documentNumber;
  final String tenantId;
  final UserRole role;
  final List<String> brandIds;
  final List<String> storeIds;
  final UserStatus status;
  final String locale;
  final String timezone;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final String? createdBy;

  AppUser copyWith({UserRole? role, UserStatus? status, List<String>? storeIds}) => AppUser(
        uid: uid,
        email: email,
        displayName: displayName,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        documentType: documentType,
        documentNumber: documentNumber,
        tenantId: tenantId,
        role: role ?? this.role,
        brandIds: brandIds,
        storeIds: storeIds ?? this.storeIds,
        status: status ?? this.status,
        locale: locale,
        timezone: timezone,
        photoUrl: photoUrl,
        createdAt: createdAt,
        updatedAt: updatedAt,
        lastLoginAt: lastLoginAt,
        createdBy: createdBy,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'documentType': documentType,
        'documentNumber': documentNumber,
        'tenantId': tenantId,
        'role': role.wire,
        'brandIds': brandIds,
        'storeIds': storeIds,
        'status': status.wire,
        'locale': locale,
        'timezone': timezone,
        'photoUrl': photoUrl,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'createdBy': createdBy,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        uid: (json['uid'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        displayName: (json['displayName'] ?? '') as String,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phone: json['phone'] as String?,
        documentType: json['documentType'] as String?,
        documentNumber: json['documentNumber'] as String?,
        tenantId: (json['tenantId'] ?? 'ajilimo') as String,
        role: userRoleFromWire(json['role'] as String?),
        brandIds: (json['brandIds'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
        storeIds: (json['storeIds'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
        status: UserStatus.values.firstWhere(
          (status) => status.name == json['status'],
          orElse: () => UserStatus.active,
        ),
        locale: (json['locale'] ?? 'es') as String,
        timezone: (json['timezone'] ?? 'America/Lima') as String,
        photoUrl: json['photoUrl'] as String?,
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
        updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
        lastLoginAt: DateTime.tryParse((json['lastLoginAt'] ?? '').toString()),
        createdBy: json['createdBy'] as String?,
      );
}
