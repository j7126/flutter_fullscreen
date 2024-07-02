A simple package which allows setting fullscreen mode on all platforms in flutter.

## Features

Allows setting full-screen mode on the following platforms:
 - Web
 - Linux
 - macOS
 - Windows
 - Android
 - IOS

## Getting started

### Install

Add to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_fullscreen: ^1.0.0
```

## Usage

### Initialization

```dart
import 'package:flutter_fullscreen/full_screen.dart';

void main() async {
    // ensure these two lines are added to main
    WidgetsFlutterBinding.ensureInitialized();
    await FullScreen.ensureInitialized();

    runApp(const MyApp());
}
```

### Setting fullscreen

```dart
// enable fullscreen
FullScreen.setFullScreen(true);

// exit fullscreen
FullScreen.setFullScreen(false);
```

### Listening to fullscreen status

```dart
import 'package:flutter/material.dart';
import 'package:flutter/src/services/system_chrome.dart';
import 'package:flutter_fullscreen/full_screen.dart';

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> with FullScreenListener {
  bool isFullScreen = FullScreen.isFullScreen;

  @override
  void initState() {
    FullScreen.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    FullScreen.removeListener(this);
    super.dispose();
  }

  @override
  void onFullScreenChanged(bool enabled, SystemUiMode? systemUiMode) {
    setState(() {
      isFullScreen = enabled;
    });
  }
}

```

Please see the example for more detailed usage.
