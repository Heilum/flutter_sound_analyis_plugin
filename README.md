![logo](./logo.png)
<br>
**Note**: Sound Analysis is only supported by iOS 15 or later

## Installation
1.open Terminal App<br>
2.cd [your project's folder]<br>
3.flutter add pub sound_analysis

## Usage
```
     import 'package:sound_analysis/sound_analysis.dart';
     import 'package:path/path.dart' as path;
     import 'package:path_provider/path_provider.dart';
    
     List<String> audios = await SoundAnalysis.knownClassifications(SoundAnalysis.SNClassifierIdentifier_version1);
     print("recognizable audios === ${audios}");
 
      Directory directory = await getApplicationDocumentsDirectory();
      var videoFilePath = path.join(directory.path,"t2.mp4");
      File file = File(videoFilePath);
      if (!file.existsSync()){
        ByteData data = await rootBundle.load("assets/t2.mp4");
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        file.writeAsBytesSync(bytes,flush: true);
      }
      List<Map<String,dynamic>> clips = await SoundAnalysis.analyzeAudioFile(SoundAnalysis.SNClassifierIdentifier_version1, videoFilePath);
      print("recognized audio clips:${clips}");
   
```

## Output
```
[+2113 ms] flutter: recognizable audios  === [speech, shout, yell, battle_cry, children_shouting, screaming, whispering, laughter, baby_laughter, giggling, snicker, belly_laugh, chuckle_chortle, crying_sobbing, baby_crying, sigh, singing, choir_singing, yodeling, rapping, humming, whistling, breathing, snoring, gasp, cough, sneeze, nose_blowing, person_running, person_shuffling, person_walking, chewing, biting, gargling, burp, hiccup, slurp, finger_snapping, clapping, cheering, applause, booing, chatter, crowd, babble, dog, dog_bark, dog_howl, dog_bow_wow, dog_growl, dog_whimper, cat, cat_purr, cat_meow, horse_clip_clop, horse_neigh, cow_moo, pig_oink, sheep_bleat, fowl, chicken, chicken_cluck, rooster_crow, turkey_gobble, duck_quack, goose_honk, lion_roar, bird, bird_vocalization, bird_chirp_tweet, bird_squawk, pigeon_dove_coo, crow_caw, owl_hoot, bird_flapping, insect, cricket_chirp, mosquito_buzz, fly_buzz, bee_buzz, frog, frog_croak, snake_hiss, snake_rattle, whale_vocalization, coyote_howl, elk_bugle<…>
```

```
[ +518 ms] flutter: recognized audio clips:[{confidence: 0.8910837173461914, audioKey: humming, duration: 3.0, startAt: 0.0}, {confidence: 0.9592931270599365, audioKey: humming, startAt: 1.5, duration: 3.0}, {confidence: 0.7030519843101501, startAt: 3.0, duration: 3.0, audioKey: laughter}, {audioKey: humming, confidence: 0.42257529497146606, duration: 3.0, startAt: 4.5}, {audioKey: humming, startAt: 6.0, duration: 3.0, confidence: 0.9056249260902405}, {confidence: 0.949840247631073, audioKey: laughter, duration: 3.0, startAt: 7.5}]
```