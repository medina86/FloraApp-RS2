class UserRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String phoneNumber;
  final String password;
  final bool isActive;
  final List<int> roleIds;

  UserRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.password,
    this.isActive = true,
    this.roleIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'username': username,
    'phoneNumber': phoneNumber,
    'password': password,
    'isActive': isActive,
    'roleIds': roleIds,
  };
}
