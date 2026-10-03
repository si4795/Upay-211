class SecurityEvent {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String deviceName;
  final String location;
  final bool isSafe;

  const SecurityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.deviceName,
    required this.location,
    this.isSafe = true,
  });
}

class TrustedDeviceInfo {
  final String deviceId;
  final String deviceName;
  final String deviceModel;
  final DateTime firstAdded;
  final DateTime lastActive;
  final bool isCurrent;

  const TrustedDeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.firstAdded,
    required this.lastActive,
    this.isCurrent = false,
  });
}

