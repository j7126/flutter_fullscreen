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

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_fullscreen/src/full_screen_listener.dart';
import 'package:flutter_fullscreen/src/full_screen.dart';
import 'package:window_manager/window_manager.dart';

/// FullScreen default platform handler.
/// This should not be used directly, instead use [FullScreen].
class FullScreenInstance with WindowListener {
  final ObserverList<FullScreenListener> _eventListeners =
      ObserverList<FullScreenListener>();

  bool _state = false;
  SystemUiMode? _systemUiMode;

  bool get state => _state;
  bool get fullScreenForced => false;
  SystemUiMode? get systemUiMode => _systemUiMode;

  FullScreenInstance();

  void _onStateChanged(bool state, SystemUiMode? systemUiMode) {
    if (_state != state || _systemUiMode != systemUiMode) {
      _state = state;
      _systemUiMode = systemUiMode;
      for (var listener in _eventListeners) {
        listener.onFullScreenChanged(_state, _systemUiMode);
        if (_state) {
          listener.onWindowEnterFullScreen(_systemUiMode);
        } else {
          listener.onWindowLeaveFullScreen(_systemUiMode);
        }
      }
    }
  }

  Future ensureInitialized() async {
    if (FullScreen.supportWindowManager) {
      await windowManager.ensureInitialized();
      windowManager.addListener(this);
      _state = await windowManager.isFullScreen();
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
    if (FullScreen.supportMobile) {
      if (systemUiMode == null) {
        if (state) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: SystemUiOverlay.values);
        }
      } else {
        if (state) {
          SystemChrome.setEnabledSystemUIMode(systemUiMode,
              overlays: systemUiOverlays);
        } else {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
              overlays: SystemUiOverlay.values);
        }
      }
      _onStateChanged(state, systemUiMode);
    } else if (FullScreen.supportWindowManager) {
      windowManager.setFullScreen(state);
    }
  }

  @override
  void onWindowEnterFullScreen() {
    _onStateChanged(true, null);
  }

  @override
  void onWindowLeaveFullScreen() {
    _onStateChanged(false, null);
  }
}
