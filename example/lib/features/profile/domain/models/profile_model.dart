class ProfileModel {
  final String name;
  final int age;
  final String profileUrl;

  const ProfileModel({
    required this.name,
    required this.age,
    required this.profileUrl,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name'],
      age: json['age'],
      profileUrl: json['url'],
    );
  }
}
