class Preferences {
  final bool notifications;
  final bool darkMode;
  final bool biometric;

  Preferences({
    this.notifications = true,
    this.darkMode = false,
    this.biometric = false,
  });

  factory Preferences.fromFirestore(Map<String, dynamic> data) {
    return Preferences(
      notifications: data['notifications'] ?? true,
      darkMode: data['darkMode'] ?? false,
      biometric: data['biometric'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'darkMode': darkMode,
      'biometric': biometric,
    };
  }

  Preferences copyWith({
    bool? notifications,
    bool? darkMode,
    bool? biometric,
  }) {
    return Preferences(
      notifications: notifications ?? this.notifications,
      darkMode: darkMode ?? this.darkMode,
      biometric: biometric ?? this.biometric,
    );
  }
}
