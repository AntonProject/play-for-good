// Custom Action ggPrecacheHeaders (Include BuildContext). Keep FF imports above.
// Decodes the large header backgrounds once at app start (called from the
// Splash On Load, not awaited), so a page with a red header does not show a
// frame without its image (white flash) the first time it opens.
// The images are pinned (keepAlive): a plain precache stays in the image cache
// only until other images (post photos, avatars) push it out, and then the
// first open of e.g. Good Games decoded its header again behind a white frame.
import 'dart:async';
import 'package:flutter/material.dart';

final List<ImageStreamCompleterHandle> _ggPinnedHeaders = [];

Future ggPrecacheHeaders(BuildContext context) async {
  if (_ggPinnedHeaders.isNotEmpty) return;
  const assets = [
    'assets/images/Wallet.png',
    'assets/images/Good_Games_-_My_games.png',
    'assets/images/Good_Score_Card2.png',
    'assets/images/Good_Score_Card3.png',
    'assets/images/Organization_profile_page3.png',
    'assets/images/user_profile_background.png',
    'assets/images/user_profile_updaded_bg.png',
    'assets/images/Good_Games_Logo_-_Standard_7_1.webp',
  ];
  final config = createLocalImageConfiguration(context);
  await Future.wait([for (final a in assets) _ggPin(AssetImage(a), config)]);
}

Future<void> _ggPin(ImageProvider provider, ImageConfiguration config) {
  final done = Completer<void>();
  final stream = provider.resolve(config);
  late final ImageStreamListener listener;
  void finish() {
    stream.removeListener(listener);
    if (!done.isCompleted) done.complete();
  }

  listener = ImageStreamListener(
    (_, __) {
      final completer = stream.completer;
      if (completer != null) _ggPinnedHeaders.add(completer.keepAlive());
      finish();
    },
    onError: (_, __) => finish(),
  );
  stream.addListener(listener);
  return done.future;
}
