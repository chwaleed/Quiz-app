import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/firebase_constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String fullName;
  final String? profilePictureUrl;
  final String role; // 'user' or 'admin'
  final int totalPoints;
  final int quizzesAttempted;
  final int quizzesPassed;
  final double averageScore;
  final DateTime createdAt;
  final DateTime lastActive;

  const UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.fullName,
    this.profilePictureUrl,
    required this.role,
    this.totalPoints = 0,
    this.quizzesAttempted = 0,
    this.quizzesPassed = 0,
    this.averageScore = 0.0,
    required this.createdAt,
    required this.lastActive,
  });

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json[FirebaseConstants.userIdField] as String,
      email: json[FirebaseConstants.userEmailField] as String,
      username: json[FirebaseConstants.userUsernameField] as String,
      fullName: json[FirebaseConstants.userFullNameField] as String,
      profilePictureUrl:
          json[FirebaseConstants.userProfilePictureField] as String?,
      role: json[FirebaseConstants.userRoleField] as String? ?? 'user',
      totalPoints: json[FirebaseConstants.userTotalPointsField] as int? ?? 0,
      quizzesAttempted:
          json[FirebaseConstants.userQuizzesCompletedField] as int? ?? 0,
      quizzesPassed: json['quizzesPassed'] as int? ?? 0,
      averageScore:
          (json[FirebaseConstants.userAverageScoreField] as num?)?.toDouble() ??
          0.0,
      createdAt:
          (json[FirebaseConstants.userCreatedAtField] as Timestamp?)
              ?.toDate() ??
          DateTime.now(),
      lastActive:
          (json[FirebaseConstants.userLastActiveField] as Timestamp?)
              ?.toDate() ??
          DateTime.now(),
    );
  }

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      FirebaseConstants.userIdField: uid,
      FirebaseConstants.userEmailField: email,
      FirebaseConstants.userUsernameField: username,
      FirebaseConstants.userFullNameField: fullName,
      FirebaseConstants.userProfilePictureField: profilePictureUrl,
      FirebaseConstants.userRoleField: role,
      FirebaseConstants.userTotalPointsField: totalPoints,
      FirebaseConstants.userQuizzesCompletedField: quizzesAttempted,
      'quizzesPassed': quizzesPassed,
      FirebaseConstants.userAverageScoreField: averageScore,
      FirebaseConstants.userCreatedAtField: Timestamp.fromDate(createdAt),
      FirebaseConstants.userLastActiveField: Timestamp.fromDate(lastActive),
    };
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? fullName,
    String? profilePictureUrl,
    String? role,
    int? totalPoints,
    int? quizzesAttempted,
    int? quizzesPassed,
    double? averageScore,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
      totalPoints: totalPoints ?? this.totalPoints,
      quizzesAttempted: quizzesAttempted ?? this.quizzesAttempted,
      quizzesPassed: quizzesPassed ?? this.quizzesPassed,
      averageScore: averageScore ?? this.averageScore,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Get pass rate percentage
  double get passRate {
    if (quizzesAttempted == 0) return 0.0;
    return (quizzesPassed / quizzesAttempted) * 100;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, username: $username, fullName: $fullName, role: $role, totalPoints: $totalPoints)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
