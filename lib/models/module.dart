class Module {
  final String id;
  final String code;
  final String name;
  final String level; // '1st Year', '2nd Year', '3rd Year'

  Module({
    required this.id,
    required this.code,
    required this.name,
    required this.level,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name, 'level': level};
  }
}
