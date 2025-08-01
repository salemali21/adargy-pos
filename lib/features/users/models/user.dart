class User {
  final String id;
  final String name;
  final String role; // admin, cashier, staff
  final String phone;
  final List<String> permissions;
  final List<String> activityLog;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.permissions,
    required this.activityLog,
    required this.password,
  });

  User copyWith({
    String? id,
    String? name,
    String? role,
    String? phone,
    List<String>? permissions,
    List<String>? activityLog,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      permissions: permissions ?? this.permissions,
      activityLog: activityLog ?? this.activityLog,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'phone': phone,
      'permissions': permissions,
      'activityLog': activityLog,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      phone: map['phone'],
      permissions: List<String>.from(map['permissions'] ?? []),
      activityLog: List<String>.from(map['activityLog'] ?? []),
      password: map['password'],
    );
  }
}
