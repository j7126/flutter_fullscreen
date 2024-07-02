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

import 'package:flutter/material.dart';
import 'package:flutter/src/services/system_chrome.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FullScreen.ensureInitialized();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with FullScreenListener {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fullscreen Example",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Text("Fullscreen Example"),
            ],
          ),
        ),
        body: Center(
          child: IconButton(
            onPressed: () {
              FullScreen.setFullScreen(!isFullScreen);
            },
            icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
        ),
      ),
    );
  }
}
