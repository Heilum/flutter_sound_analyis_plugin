
import 'dart:async';

import 'package:flutter/services.dart';

class SoundAnalysis {
  static const MethodChannel _channel = MethodChannel('sound_analysis');

  static const SNClassifierIdentifier_version1 = "com.apple.SoundAnalysis.classifier.v1";

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List<String>> knownClassifications(String version) async{
    final List<Object?> audios = await _channel.invokeMethod('knownClassifications',[version]);
    return audios.map((e) => e as String).toList();
  }

  static Future<List<Map<String,dynamic>>> analyzeAudioFile(String version,String filePath) async{
    final List<Object?> audios = await _channel.invokeMethod('analyzeAudioFile',[version,filePath]);
    return audios.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }



}
