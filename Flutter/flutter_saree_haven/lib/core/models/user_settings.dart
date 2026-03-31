class UserSettings {
  final String userId;
  final bool pushNotifications;
  final bool promotionalEmails;
  final bool darkMode;

  UserSettings({
    required this.userId,
    this.pushNotifications = true,
    this.promotionalEmails = false,
    this.darkMode = false,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'] ?? '',
      pushNotifications: (json['push_notifications'] == 1 || json['push_notifications'] == true),
      promotionalEmails: (json['promotional_emails'] == 1 || json['promotional_emails'] == true),
      darkMode: (json['dark_mode'] == 1 || json['dark_mode'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'push_notifications': pushNotifications ? 1 : 0,
      'promotional_emails': promotionalEmails ? 1 : 0,
      'dark_mode': darkMode ? 1 : 0,
    };
  }

  UserSettings copyWith({
    String? userId,
    bool? pushNotifications,
    bool? promotionalEmails,
    bool? darkMode,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      promotionalEmails: promotionalEmails ?? this.promotionalEmails,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
