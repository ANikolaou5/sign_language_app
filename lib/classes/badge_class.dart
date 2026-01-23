class BadgeClass {
  final int badgeNum;
  final int lessonNum;
  final String badgeName;
  final String badgeDesc;
  final String badgeImage;

  BadgeClass({
    required this.badgeNum,
    required this.lessonNum,
    required this.badgeName,
    required this.badgeDesc,
    required this.badgeImage,
  });

  factory BadgeClass.fromFirebase(Map<String, dynamic> data) {
    return BadgeClass(
      badgeNum: data['badgeNum'] ?? 0,
      lessonNum: data['lessonNum'] ?? 0,
      badgeName: data['badgeName'] ?? '',
      badgeDesc: data['badgeDesc'] ?? '',
      badgeImage: data['badgeImage'] ?? '',
    );
  }
}