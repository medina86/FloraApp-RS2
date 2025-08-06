class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? phoneNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? profileImageUrl;
  final List<RoleModel>? roles;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.phoneNumber,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
    this.profileImageUrl,
    this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<RoleModel>? roles;
    if (json['roles'] != null) {
      roles = (json['roles'] as List<dynamic>)
          .map((roleJson) => RoleModel.fromJson(roleJson))
          .toList();
    }

    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      username: json['username'],
      phoneNumber: json['phoneNumber'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      profileImageUrl: json['profileImageUrl'],
      roles: roles,
    );
  }

  String get fullName => "$firstName $lastName";
}

class RoleModel {
  final int id;
  final String name;
  final String? description;

  RoleModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
