import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stats.dart';
import '../services/stats_service.dart';

class StatsProvider extends ChangeNotifier {
  final StatsService _statsService = StatsService();
  StreamSubscription? _subscription;
  Stats _stats = Stats();
  bool _isLoading = true;

  Stats get stats => _stats;
  bool get isLoading => _isLoading;

  void startListening(String uid) {
    _subscription?.cancel();
    _subscription = _statsService.streamStats(uid).listen((stats) {
      _stats = stats;
      _isLoading = false;
      notifyListeners();
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> updateStats(String uid, Map<String, dynamic> data) async {
    await _statsService.updateStats(uid, data);
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
