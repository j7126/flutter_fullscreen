/*
flutter_fullscreen

Copyright (c) 2024 Jefferey Neuffer <jeff@jefferey.dev>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart';

import 'package:flutter_fullscreen/src/full_screen_listener.dart';
import 'package:flutter_fullscreen/src/full_screen.dart';

extension on Element {
  // ignore: unused_element
  external JSPromise<JSAny?> requestFullscreen([JSObject options]);
}

extension on Document {
  // ignore: unused_element
  external JSPromise<JSAny?> exitFullscreen([JSObject options]);
  external Element? get fullscreenElement;
}

/// FullScreen web platform handler.
/// This should not be used directly, instead use [FullScreen].
class FullScreenInstance {
  final ObserverList<FullScreenListener> _eventListeners = ObserverList<FullScreenListener>();

  bool _state = false;
  bool _fullScreenForced = false;

  bool get state => _state;
  bool get fullScreenForced => _fullScreenForced && !_state;
  SystemUiMode? get systemUiMode => null;

  FullScreenInstance();

  void _onStateChanged(bool state) {
    if (_state != state) {
      _state = state;
      for (var listener in _eventListeners) {
        listener.onFullScreenChanged(state, null);
        if (state) {
          listener.onWindowEnterFullScreen(null);
        } else {
          listener.onWindowLeaveFullScreen(null);
        }
      }
      _fullScreenForcedChanged();
    }
  }

  void _fullScreenForcedChanged() {
    for (var listener in _eventListeners) {
      listener.onFullScreenForcedChanged(fullScreenForced);
    }
  }

  void _handleFullScreenChange() {
    _onStateChanged(window.document.fullscreenElement != null);
  }

  void _handleResize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    var isForced = window.screen.width == window.outerWidth && window.screen.height == window.outerHeight;
    var prev = fullScreenForced;
    if (isForced != _fullScreenForced) {
      _fullScreenForced = isForced;
      if (prev != _fullScreenForced) {
        _fullScreenForcedChanged();
      }
    }
  }

  Future ensureInitialized() async {
    if (FullScreen.supportWeb && window.document.documentElement != null) {
      _handleFullScreenChange();
      _handleResize();
      const EventStreamProvider<Event>('fullscreenchange')
          .forElement(window.document.documentElement!)
          .listen((_) => _handleFullScreenChange());
      const EventStreamProvider<Event>('resize').forTarget(window).listen((_) => _handleResize());
    }
  }

  void addListener(FullScreenListener listener) {
    if (!_eventListeners.contains(listener)) {
      _eventListeners.add(listener);
    }
  }

  void removeListener(FullScreenListener listener) {
    _eventListeners.remove(listener);
  }

  void setState(
    bool state,
    SystemUiMode? systemUiMode,
    List<SystemUiOverlay>? systemUiOverlays,
  ) {
    if (FullScreen.supportWeb) {
      if (state) {
        window.document.documentElement?.requestFullscreen();
      } else {
        window.document.exitFullscreen();
      }
    }
  }
}
