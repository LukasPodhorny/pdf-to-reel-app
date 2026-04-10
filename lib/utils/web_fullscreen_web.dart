import 'package:web/web.dart' as web;

bool isFullscreen() {
  return web.document.fullscreenElement != null;
}

void toggleFullscreen() {
  if (isFullscreen()) {
    web.document.exitFullscreen();
  } else {
    web.document.documentElement?.requestFullscreen();
  }
}
