/// User Model
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String subscriptionType;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.subscriptionType,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? json['displayName'] as String,
      subscriptionType: json['subscription_type'] as String? ?? json['subscriptionType'] as String,
      subscriptionStartDate: json['subscription_start_date'] as String? ?? json['subscriptionStartDate'] as String?,
      subscriptionEndDate: json['subscription_end_date'] as String? ?? json['subscriptionEndDate'] as String?,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String,
      updatedAt: json['updated_at'] as String? ?? json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'subscription_type': subscriptionType,
      'subscription_start_date': subscriptionStartDate,
      'subscription_end_date': subscriptionEndDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isVip => subscriptionType == 'vip';

  bool get isSubscriptionActive {
    if (!isVip) return false;
    if (subscriptionEndDate == null) return false;

    final endDate = DateTime.parse(subscriptionEndDate!);
    return endDate.isAfter(DateTime.now());
  }
}

class AuthResponse {
  final UserModel user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'token': token,
    };
  }
}
