/*
full_screen

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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:full_screen/src/full_screen_listener.dart';
import 'package:full_screen/src/full_screen_instance.dart'
    if (dart.library.js_util) 'package:full_screen/src/full_screen_instance_web.dart';

/// Manages full-screen.
class FullScreen {
  static const bool supportWeb = kIsWeb;
  static final bool supportWindowManager = !supportWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);
  static final bool supportMobile = !supportWeb && (Platform.isAndroid || Platform.isIOS);

  static bool _initialized = false;

  static late FullScreenInstance _instance;

  static void _assertInitialized() {
    if (!_initialized) {
      throw "FullScreen is not initialized. Please await FullScreen.ensureInitialized() first!";
    }
    assert(_initialized);
  }

  /// Is full-screen mode currently enabled.
  static bool get isFullScreen {
    _assertInitialized();
    return _instance.state;
  }

  /// Is full-screen currently forced by the environment.
  /// If full-screen is forced, it cannot be disabled.
  static bool get isFullScreenForced {
    _assertInitialized();
    return _instance.fullScreenForced;
  }

  /// The current [SystemUiMode] on mobile platforms.
  static SystemUiMode? get systemUiMode {
    _assertInitialized();
    return _instance.systemUiMode;
  }

  /// Ensures that [FullScreen] has been initialized.
  /// Must be invoked before using [FullScreen].
  static Future<void> ensureInitialized() async {
    if (!(supportWindowManager || supportWeb || supportMobile)) {
      throw "This platform is not supported.";
    }

    if (_initialized) {
      return;
    }

    _instance = FullScreenInstance();
    await _instance.ensureInitialized();
    _initialized = true;
  }

  /// Adds a listener for full-screen state changes.
  static void addListener(FullScreenListener listener) {
    _assertInitialized();
    _instance.addListener(listener);
  }

  /// Removes a listener for full-screen state changes.
  static void removeListener(FullScreenListener listener) {
    _assertInitialized();
    _instance.removeListener(listener);
  }

  /// Sets full-screen state.
  static void setFullScreen(
    bool enabled, {
    SystemUiMode? systemUiMode,
    List<SystemUiOverlay>? systemUiOverlays,
  }) {
    _assertInitialized();
    _instance.setState(enabled, systemUiMode, systemUiOverlays);
  }
}
