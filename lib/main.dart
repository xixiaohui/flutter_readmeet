import 'package:flutter/cupertino.dart';
import 'app.dart';
import 'services/api_service.dart';

void main() {
  final apiService = ApiService();
  runApp(App(apiService: apiService));
}
