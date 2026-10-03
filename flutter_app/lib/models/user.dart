class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatarUrl;
  final int accountAgeDays;
  final List<String> trustedDevices;
  final String currentDeviceId;
  final String currentLocation;
  final bool isFlagged;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatarUrl,
    this.accountAgeDays = 320,
    this.trustedDevices = const ['DEVICE001', 'DEVICE002'],
    this.currentDeviceId = 'DEVICE001',
    this.currentLocation = 'Dhaka, Bangladesh',
    this.isFlagged = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    int? accountAgeDays,
    List<String>? trustedDevices,
    String? currentDeviceId,
    String? currentLocation,
    bool? isFlagged,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      accountAgeDays: accountAgeDays ?? this.accountAgeDays,
      trustedDevices: trustedDevices ?? this.trustedDevices,
      currentDeviceId: currentDeviceId ?? this.currentDeviceId,
      currentLocation: currentLocation ?? this.currentLocation,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatarUrl': avatarUrl,
      'accountAgeDays': accountAgeDays,
      'trustedDevices': trustedDevices,
      'currentDeviceId': currentDeviceId,
      'currentLocation': currentLocation,
      'isFlagged': isFlagged,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? 'USER001',
      name: json['name'] as String? ?? 'Demo User',
      phone: json['phone'] as String? ?? '01700000000',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      accountAgeDays: json['accountAgeDays'] as int? ?? 320,
      trustedDevices: (json['trustedDevices'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['DEVICE001'],
      currentDeviceId: json['currentDeviceId'] as String? ?? 'DEVICE001',
      currentLocation: json['currentLocation'] as String? ?? 'Dhaka, Bangladesh',
      isFlagged: json['isFlagged'] as bool? ?? false,
    );
  }
}
