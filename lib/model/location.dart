import 'dart:convert';

class Location {
    String? pseudo;
    String? numero;
    String? long;
    String? lat;
    String? id;

    Location({
        this.pseudo,
        this.numero,
        this.long,
        this.lat,
        this.id,
    });

    factory Location.fromRawJson(String str) => Location.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        pseudo: json["pseudo"],
        numero: json["numero"],
        long: json["long"],
        lat: json["lat"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "pseudo": pseudo,
        "numero": numero,
        "long": long,
        "lat": lat,
        "id": id,
    };
}
