// To parse this JSON data, do
//
//     final revisedpost = revisedpostFromJson(jsonString);

import 'dart:convert';

List<Revisedpost> revisedpostFromJson(String str) => List<Revisedpost>.from(json.decode(str).map((x) => Revisedpost.fromJson(x)));

String revisedpostToJson(List<Revisedpost> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Revisedpost {
  String? id;
  String? name;
  String? qualification;
  String? about;
  int? chargespm;
  List<Disorder>? disorders;
  int? mobileno;
  String? emailid;
  String? imagepath;
  DateTime? createdAt;
  int? v;

  Revisedpost({
    this.id,
    this.name,
    this.qualification,
    this.about,
    this.chargespm,
    this.disorders,
    this.mobileno,
    this.emailid,
    this.imagepath,
    this.createdAt,
    this.v,
  });

  factory Revisedpost.fromJson(Map<String, dynamic> json) => Revisedpost(
    id: json["_id"],
    name: json["name"],
    qualification: json["qualification"],
    about: json["about"],
    chargespm: json["chargespm"],
    disorders: json["disorders"] == null ? [] : List<Disorder>.from(json["disorders"]!.map((x) => Disorder.fromJson(x))),
    mobileno: json["mobileno"],
    emailid: json["emailid"],
    imagepath: json["imagepath"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "qualification": qualification,
    "about": about,
    "chargespm": chargespm,
    "disorders": disorders == null ? [] : List<dynamic>.from(disorders!.map((x) => x.toJson())),
    "mobileno": mobileno,
    "emailid": emailid,
    "imagepath": imagepath,
    "createdAt": createdAt?.toIso8601String(),
    "__v": v,
  };
}

class Disorder {
  DisorderName? disorderName;
  String? id;

  Disorder({
    this.disorderName,
    this.id,
  });

  factory Disorder.fromJson(Map<String, dynamic> json) => Disorder(
    disorderName: disorderNameValues.map[json["disorder_name"]]!,
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "disorder_name": disorderNameValues.reverse[disorderName],
    "_id": id,
  };
}

enum DisorderName {
  ADHD,
  ANXIETY,
  STRESS
}

final disorderNameValues = EnumValues({
  "ADHD": DisorderName.ADHD,
  "Anxiety": DisorderName.ANXIETY,
  "Stress": DisorderName.STRESS
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
