class UserModel {
  final String uid;
  final String name;
  final String email;
  final String cookingLevel;
  final String favoriteCuisine;
  final String dietaryPreference;
  final String avatarIcon;
  final int totalStars;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.cookingLevel = 'Beginner Chef',
    this.favoriteCuisine = 'Filipino Food',
    this.dietaryPreference = 'None',
    this.avatarIcon = 'chef',
    this.totalStars = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'cookingLevel': cookingLevel,
      'favoriteCuisine': favoriteCuisine,
      'dietaryPreference': dietaryPreference,
      'avatarIcon': avatarIcon,
      'totalStars': totalStars,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      cookingLevel: map['cookingLevel'] ?? 'Beginner Chef',
      favoriteCuisine: map['favoriteCuisine'] ?? 'Filipino Food',
      dietaryPreference: map['dietaryPreference'] ?? 'None',
      avatarIcon: map['avatarIcon'] ?? 'chef',
      totalStars: map['totalStars'] ?? 0,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? cookingLevel,
    String? favoriteCuisine,
    String? dietaryPreference,
    String? avatarIcon,
    int? totalStars,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      cookingLevel: cookingLevel ?? this.cookingLevel,
      favoriteCuisine: favoriteCuisine ?? this.favoriteCuisine,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      avatarIcon: avatarIcon ?? this.avatarIcon,
      totalStars: totalStars ?? this.totalStars,
    );
  }
}