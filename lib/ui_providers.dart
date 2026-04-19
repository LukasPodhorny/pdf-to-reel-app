import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/reel_models.dart';

// UI State (Local)
final isGenerateModeProvider = StateProvider<bool>((ref) => true);
final reelCountProvider = StateProvider<double>((ref) => 1.0);

// Auth State
final loginEmailProvider = StateProvider<String>((ref) => '');
final signupEmailProvider = StateProvider<String>((ref) => '');
final needsVerificationProvider = StateProvider<bool>((ref) => false);

// Selections for Generation
const int kMaxSelectedAvatars = 4;
final selectedAvatarNamesProvider = StateProvider<Set<String>>((ref) => {});
final selectedTemplateNameProvider = StateProvider<String?>((ref) => null);
final selectedTemplateProvider = StateProvider<VideoTemplate?>((ref) => null);
final promptTextProvider = StateProvider<String>((ref) => '');
final uploadedFileKeysProvider = StateProvider<List<String>>((ref) => []);

// Per-template enabled tags: template.name -> set of enabled asset_type strings.
// Initialized from each template's defaults the first time the template is seen.
final enabledTagsByTemplateProvider =
    StateProvider<Map<String, Set<String>>>((ref) => {});

// App Data State
final selectedSeriesProvider = StateProvider<VideoSeries?>((ref) => null);

// Desktop Navigation
enum DesktopTab { generate, videos, account }
final desktopTabProvider = StateProvider<DesktopTab>((ref) => DesktopTab.generate);
