import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/reel_models.dart';

// UI State (Local)
final isGenerateModeProvider = StateProvider<bool>((ref) => true);
final reelCountProvider = StateProvider<double>((ref) => 4.0);
final selectedProfileIndicesProvider = StateProvider<Set<int>>((ref) => {0});

// User Data (To be connected to backend / remote state)
final diamondCountProvider = StateProvider<int>((ref) => 100);

// App Data State
final selectedSeriesProvider = StateProvider<VideoSeries?>((ref) => null);
