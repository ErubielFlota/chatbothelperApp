import 'dart:convert';
import 'package:http/http.dart' as http;

class AuroraApi {
  static const String baseUrl =
      "https://api-bot-flutter.onrender.com";

  static Future<Map<String, dynamic>> enviarMensaje(
      String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/enviar_mensaje"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "mensaje": mensaje,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception(
        "Error ${response.statusCode}: ${response.body}",
      );
    } catch (e) {
      throw Exception(
        "No fue posible conectar con Aurora.\n$e",
      );
    }
  }
}