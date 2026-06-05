import 'dart:convert';
import 'package:drift/drift.dart';

class JsonStringConverter extends TypeConverter<List<String>, String> {
  const JsonStringConverter();

  @override
  List<String> fromSql(String fromDb) {
    return (jsonDecode(fromDb) as List).cast<String>();
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}
