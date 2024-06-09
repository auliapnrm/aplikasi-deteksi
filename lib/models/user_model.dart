class UserModel {
  final int userId;
  final String username;
  final String namaLengkap;
  final String accessToken;

  UserModel({
    required this.userId,
    required this.username,
    required this.namaLengkap,
    required this.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      username: json['username'],
      namaLengkap: json['nama_lengkap'],
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'nama_lengkap': namaLengkap,
      'access_token': accessToken,
    };
  }
}
