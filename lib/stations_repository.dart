import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StationsRepository {
  static const _stationsKey = "stations";

  Future<List<Station>> loadStations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_stationsKey);
    if (jsonString == null || jsonString.isEmpty) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Station.fromJson(e)).toList();
  }

  Future<void> saveStations(List<Station> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(stations.map((s) => s.toJson()).toList());
    await prefs.setString(_stationsKey, jsonString);
  }

  Future<void> addStation(Station station) async {
    final stations = await loadStations();
    stations.add(station);
    await saveStations(stations);
  }

  Future<void> removeStation(String id) async {
    final stations = await loadStations();
    stations.removeWhere((s) => s.id == id);
    await saveStations(stations);
  }

  Future<void> clearStations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stationsKey);
  }
}
