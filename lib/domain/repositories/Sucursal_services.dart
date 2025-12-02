import 'dart:convert';

import 'package:facelock/config/constants/enviroment.dart';
import 'package:facelock/domain/entities/sucursal.dart';
import 'package:http/http.dart' as http;

class SucursalService {
  static final String _baseUrl = Environment.urlBase;

  Future<SucursalResponse> getSucursales() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/sucursales/'),
      headers: {
        "X-API-Name": Environment.xApiName,
            "X-API-Version": Environment.xApiVersion,
            "X-Developed-By": Environment.xDevelopedBy,
            "X-Code": Environment.xCode
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return SucursalResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load sucursales. Status: ${response.statusCode}');
    }
  }
}