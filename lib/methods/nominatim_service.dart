import 'package:http/http.dart' as http;
import 'dart:convert';

class NominatimService {
  Future<List<String>> fetchAddressSuggestions(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      List<String> suggestions = [];

      for (var result in data) {
        String displayName = result['display_name'];
        suggestions.add(displayName);
      }

      return suggestions;
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }
}
