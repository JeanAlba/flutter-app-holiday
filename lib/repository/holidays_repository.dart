import 'dart:convert';
import 'package:flutterapp/models/holidays_model.dart';
import 'package:http/http.dart' as http;

class FeriadoService {
  Future<List<HolidaysModel>> getFeriados({int? year}) async {
    final int currentYear = year ?? 2023;

    final response = await http.get(
      Uri.parse('https://brasilapi.com.br/api/feriados/v1/$currentYear'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((e) => HolidaysModel.fromJson(e)).toList();
    } else {
      throw Exception(
        'Erro ao buscar feriados para o ano $currentYear. Status: ${response.statusCode}',
      );
    }
  }
}
