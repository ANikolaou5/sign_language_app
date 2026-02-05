class BadgeClass {
  final int badgeNum;
  final int levelNum;
  final int size;
  final String badgeName;
  final String badgeDesc;
  final String badgeImage;
  final int streak;

  BadgeClass({
    required this.badgeNum,
    required this.levelNum,
    required this.size,
    required this.badgeName,
    required this.badgeDesc,
    required this.badgeImage,
    required this.streak,
  });

  factory BadgeClass.fromFirebase(Map<String, dynamic> data) {
    return BadgeClass(
      badgeNum: data['badgeNum'] ?? 0,
      levelNum: data['levelNum'] ?? 0,
      size: data['size'] ?? 0,
      badgeName: data['badgeName'] ?? '',
      badgeDesc: data['badgeDesc'] ?? '',
      badgeImage: data['badgeImage'] ?? '',
      streak: data['streak'] ?? 0,
    );
  }

  factory BadgeClass.fromMap(Map<String, dynamic> map) {
    return BadgeClass(
      badgeNum: map['badgeNum'] ?? 0,
      levelNum: map['levelNum'] ?? 0,
      size: map['size'] ?? 0,
      badgeName: map['badgeName'] ?? '',
      badgeDesc: map['badgeDesc'] ?? '',
      badgeImage: map['badgeImage'] ?? '',
      streak: map['streak'] ?? 0,
    );
  }
}