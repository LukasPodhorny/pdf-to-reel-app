import 'package:flutter_riverpod/flutter_riverpod.dart';

final isGenerateModeProvider = StateProvider<bool>((ref) => true);
final reelCountProvider = StateProvider<double>((ref) => 4.0);
final selectedProfileIndexProvider = StateProvider<int>((ref) => 0);
final diamondCountProvider = StateProvider<int>((ref) => 100);
