import 'dart:convert';

List<Usuari> usuariFromJson(String str) =>
    List<Usuari>.from(json.decode(str).map((x) => Usuari.fromJson(x)));

String usuariToJson(List<Usuari> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Usuari {
  int pk;
  dynamic foto;
  String email;
  String username;
  String? firstFamilyName;
  String? secondFamilyName;

  Usuari({
    required this.pk,
    required this.foto,
    required this.email,
    required this.username,
    required this.firstFamilyName,
    required this.secondFamilyName,
  });

  factory Usuari.fromJson(Map<String, dynamic> json) => Usuari(
        pk: json["pk"],
        foto: json["foto"],
        email: json["email"],
        username: json["username"],
        firstFamilyName: json["first_family_name"],
        secondFamilyName: json["second_family_name"],
      );

  Map<String, dynamic> toJson() => {
        "pk": pk,
        "foto": foto,
        "email": email,
        "username": username,
        "first_family_name": firstFamilyName,
        "second_family_name": secondFamilyName,
      };
}
