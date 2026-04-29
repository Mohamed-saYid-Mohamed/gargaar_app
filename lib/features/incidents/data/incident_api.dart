import 'dart:convert';
import 'package:http/http.dart' as http;

class IncidentApi {
  static const baseUrl = 'http://YOUR_SERVER/api';

  Future<Map<String, dynamic>> submitIncident(
      Map<String, dynamic> payload) async {
    final res = await http.post(
      Uri.parse('$baseUrl/incidents'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Submit failed');
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> fetchIncident(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/incidents/$id'));
    if (res.statusCode != 200) {
      throw Exception('Fetch failed');
    }
    return jsonDecode(res.body);
  }
}
