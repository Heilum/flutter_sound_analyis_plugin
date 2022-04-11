import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:sound_analysis/sound_analysis.dart';
import 'package:flutter/services.dart' show rootBundle;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await SoundAnalysis.platformVersion ?? 'Unknown platform version';

      List<String> audios = await SoundAnalysis.knownClassifications(SoundAnalysis.SNClassifierIdentifier_version1);
      print("audios === ${audios}");


      Directory directory = await getApplicationDocumentsDirectory();
      var videoFilePath = path.join(directory.path,"t2.mp4");
      File file = File(videoFilePath);
      if (!file.existsSync()){
        ByteData data = await rootBundle.load("assets/t2.mp4");
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        file.writeAsBytesSync(bytes,flush: true);
      }
      List<Map<String,dynamic>> clips = await SoundAnalysis.analyzeAudioFile(SoundAnalysis.SNClassifierIdentifier_version1, videoFilePath);

      print("audio clips:${clips}");


    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
