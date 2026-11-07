import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:my_expense/core/constant/api_base.dart';
import 'package:my_expense/core/constant/secure_store.dart';

class ApiService {
  var client = https.Client();

  Future addUser(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final url = Uri.parse('${ApiBaseUrl.apiBaseurl}$endpoint');

    const header = {'Content-Type': 'application/json'};

    try {
      final response = await client.post(
        url,
        headers: header,
        body: jsonEncode(body),
      );
      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      if (response.statusCode == 201 || response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      }
    } catch (e) {
      return e;
    }
  }

  Future verifiyUser(
    String endpoint,
    Map<String, dynamic> body, {
    bool isForm = false,
  }) async {
    final url = Uri.parse('${ApiBaseUrl.apiBaseurl}$endpoint');

    const header = {'Content-Type': 'application/x-www-form-urlencoded'};

    try {
      final response = await client.post(
        url,
        headers: header,
        body: body.map((k, v) => MapEntry(k, v.toString())),
      );
      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};
      if (response.statusCode == 200) {
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      }
    } catch (e) {
      return e;
    }
  }

  Future addDetails(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiBaseUrl.apiBaseurl}$endpoint');

    final token = await TokenStorage.getToken();

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await client.post(
        url,
        headers: header,
        body: jsonEncode(body),
      );
      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};

      if (response.statusCode == 201) {
        return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
      }
    } catch (e) {
      return e;
    }
  }

  Future getDetails(String endpoint) async {
    final url = Uri.parse('${ApiBaseUrl.apiBaseurl}$endpoint');

    final token = await TokenStorage.getToken();

    final header = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await client.get(url, headers: header);
      final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : [];
      if (response.statusCode == 200) {
        return decoded;
      }
    } catch (e) {
      return e;
    }
  }
}
