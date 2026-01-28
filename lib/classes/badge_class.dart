class BadgeClass {
  final int badgeNum;
  final int levelNum;
  final int size;
  final String badgeName;
  final String badgeDesc;
  final String badgeImage;

  BadgeClass({
    required this.badgeNum,
    required this.levelNum,
    required this.size,
    required this.badgeName,
    required this.badgeDesc,
    required this.badgeImage,
  });

  factory BadgeClass.fromFirebase(Map<String, dynamic> data) {
    return BadgeClass(
      badgeNum: data['badgeNum'] ?? 0,
      levelNum: data['levelNum'] ?? 0,
      size: data['size'] ?? 0,
      badgeName: data['badgeName'] ?? '',
      badgeDesc: data['badgeDesc'] ?? '',
      badgeImage: data['badgeImage'] ?? '',
    );
  }

  factory BadgeClass.fromMap(Map<String, dynamic> map) {
    return BadgeClass(
      badgeNum: map['badgeNum'],
      levelNum: map['levelNum'],
      size: map['size'],
      badgeName: map['badgeName'],
      badgeDesc: map['badgeDesc'],
      badgeImage: map['badgeImage'],
    );
  }
}