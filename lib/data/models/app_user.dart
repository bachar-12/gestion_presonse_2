class AppUser {
  final String id;
  final String role; // 'teacher' | 'student'
  final String name;
  final String email;

  const AppUser({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      role: (data['role'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'name': name,
      'email': email,
    };
  }
}

