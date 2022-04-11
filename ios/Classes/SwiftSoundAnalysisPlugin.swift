import Flutter
import UIKit

public class SwiftSoundAnalysisPlugin: NSObject, FlutterPlugin {
    
    
    private var parser:SFSoundAnalyzer?
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sound_analysis", binaryMessenger: registrar.messenger())
    let instance = SwiftSoundAnalysisPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      let method = call.method
      print("method = \(method)");
      if method == "getPlatformVersion" {
          result("iOS " + UIDevice.current.systemVersion)
      }else if (method == "knownClassifications"){
          if let args = call.arguments as? [String],
             let classifierIdentifier = args.first {
              
              self.parser = SFSoundAnalyzer(version: classifierIdentifier);
              result(self.parser!.knownClassifications);
              
            } else {
              result(FlutterError.init(code: "bad args", message: "version parameter must be given", details: nil))
            }
      }else if (method == "analyzeAudioFile"){
          if let args = call.arguments as? [String],args.count == 2{
              let version = args[0]
              let path = args[1]
              self.parser = SFSoundAnalyzer(version: version);
              func callbackFun(audioResult:[[String:Any]]){
                  result(audioResult);
              }
           
              self.parser?.parseAudioFile(path: path, callback: callbackFun);
              
              
            } else {
              result(FlutterError.init(code: "bad args", message: "paraments:version,audio_path", details: nil))
            }
      }
      
      
      else{
          result(FlutterError.init(code: "unimplemented method", message: "unimplemented method = \(method)", details: nil))
      }
   
  }
}
