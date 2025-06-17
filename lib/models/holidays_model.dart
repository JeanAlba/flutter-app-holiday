class HolidaysModel {
  String? id;
  String? name;
  String? date;
  String? type;

  HolidaysModel({this.id, this.name, this.date, this.type});

  static HolidaysModel fromJson(Map<String, dynamic> json) {
    return HolidaysModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      type: json['type'] ?? '',
    );
  }

  static Map<String, dynamic> toJson(HolidaysModel holidaysModel) {
    Map<String, dynamic> json = {
      'name': holidaysModel.name,
      'date': holidaysModel.date,
      'type': holidaysModel.type,
    };
    return json;
  }
}
