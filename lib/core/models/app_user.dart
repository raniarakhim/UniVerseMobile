import 'package:diplomka/core/utils/phone_utils.dart' show normalizePhone;

class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    this.university = 'SKSU',
    this.faculty = '',
    this.yearOfStudy = '',
    this.city = 'Shymkent',
    this.photoUrl = '',
    this.resumeUrl = '',
    this.resumeFileName = '',
    this.createdAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String university;
  final String faculty;
  final String yearOfStudy;
  final String city;
  final String photoUrl;
  final String resumeUrl;
  final String resumeFileName;
  final DateTime? createdAt;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    if (fullName.isNotEmpty) return fullName[0].toUpperCase();
    return '?';
  }

  String get homeSubtitle {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '$city · ${months[now.month - 1]} ${now.day}';
  }

  Map<String, dynamic> toFirestore({bool includeCreatedAt = false}) {
    final data = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'phoneNormalized': normalizePhone(phone),
      'university': university,
      'faculty': faculty,
      'yearOfStudy': yearOfStudy,
      'city': city,
      if (photoUrl.isNotEmpty) 'photoUrl': photoUrl,
      if (resumeUrl.isNotEmpty) 'resumeUrl': resumeUrl,
      if (resumeFileName.isNotEmpty) 'resumeFileName': resumeFileName,
    };
    if (includeCreatedAt) {
      data['createdAt'] = DateTime.now().toUtc().toIso8601String();
    }
    return data;
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? university,
    String? faculty,
    String? yearOfStudy,
    String? city,
    String? photoUrl,
    String? resumeUrl,
    String? resumeFileName,
  }) {
    return AppUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      university: university ?? this.university,
      faculty: faculty ?? this.faculty,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      city: city ?? this.city,
      photoUrl: photoUrl ?? this.photoUrl,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      createdAt: createdAt,
    );
  }

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    final created = data['createdAt'];
    return AppUser(
      uid: uid,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      university: data['university'] as String? ?? 'SKSU',
      faculty: data['faculty'] as String? ?? '',
      yearOfStudy: data['yearOfStudy'] as String? ?? '',
      city: data['city'] as String? ?? 'Shymkent',
      photoUrl: data['photoUrl'] as String? ?? '',
      resumeUrl: data['resumeLocalPath'] as String? ??
          data['resumeUrl'] as String? ??
          '',
      resumeFileName: data['resumeFileName'] as String? ?? '',
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }
}
