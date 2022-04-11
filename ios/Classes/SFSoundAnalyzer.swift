//
//  SoundAnalysisParser.swift
//  sound_analysis
//
//  Created by Forever Positive on 2022/4/6.
//

import Foundation
import SoundAnalysis
import AVFoundation

class SFSoundAnalyzer{
    private let version:String;
    private var analyzer:SNAudioFileAnalyzer?
    private var observer:ResultsObserver?
    init(version:String) {
        self.version = version;
    }
    private func makeRequest() ->SNClassifySoundRequest?{
        let id = SNClassifierIdentifier(rawValue: version)
        return try? SNClassifySoundRequest(classifierIdentifier: id)
    }
    
    var  knownClassifications:[String]{
        if let request = makeRequest(){
            return request.knownClassifications;
        }else{
            return [String]();
        }
    }
    
    public func parseAudioFile(path:String,callback:@escaping ([[String:Any]])->Void){
        
        
        if let request = makeRequest(),  let analyzer = try? SNAudioFileAnalyzer(url: URL(fileURLWithPath: path)){
            
            self.analyzer = analyzer;
            
            self.observer = ResultsObserver(callback: callback);
            
            if let _ = try? analyzer.add(request, withObserver: self.observer!){
                
                DispatchQueue.global().async {
                    analyzer.analyze();
                }
                
            }
            
        }
        
        
    }
    public func extractAudioClip(sourcePath:String,timeRange:CMTimeRange,outputPath:String,callback:@escaping (Bool,String)->Void){
        
        // Create a composition
        let composition = AVMutableComposition()
        do {
            let sourceUrl = URL(fileURLWithPath: sourcePath)
            let asset = AVURLAsset(url: sourceUrl)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else {
                callback(false,"no audio track found");
                return
                
            }
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                callback(false,"can't add mutable track");
                return
                
            }
            try audioCompositionTrack.insertTimeRange(timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            print(error)
            callback(false,"insertTimeRange error:\(error)");
        }
        
        // Get url for output
        let outputUrl = URL(fileURLWithPath: outputPath)
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(atPath: outputUrl.path)
        }
        
        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = outputUrl
        
        // Export file
        exportSession.exportAsynchronously {
            guard case exportSession.status = AVAssetExportSession.Status.completed else { return }
            
            DispatchQueue.main.async {
                // Present a UIActivityViewController to share audio file
                guard let outputURL = exportSession.outputURL else {
                    callback(false,"can't export audio");
                    return
                    
                }
                callback(true,outputURL.path);
            }
        }
        
        
        
        
    }
    
}



/// An observer that receives results from a classify sound request.
class ResultsObserver: NSObject, SNResultsObserving {
    
    private var callback:([[String:Any]]) -> Void;
    private var analysisResult = [[String:Any]]();
    
    init(callback:@escaping ([[String:Any]]) -> Void) {
        self.callback = callback;
        super.init()
    }
    
    /// Notifies the observer when a request generates a prediction.
    func request(_ request: SNRequest, didProduce result: SNResult) {
        
        
        // Downcast the result to a classification result.
        guard let result = result as? SNClassificationResult else  { return }
        
        // Get the prediction with the highest confidence.
        guard let classification = result.classifications.first else { return }
        
        // Get the starting time.
        let timeInSeconds = result.timeRange.start.seconds
        
        let duration = result.timeRange.duration.seconds;
        
        // Convert the time to a human-readable string.
        let formattedTime = String(format: "%.2f,duration=%.2f", timeInSeconds,duration)
        print("Analysis result for audio at time: \(formattedTime),")
        
        // Convert the confidence to a percentage string.
        let percent = classification.confidence * 100.0
        let percentString = String(format: "%.2f%%", percent)
        
        // Print the classification's name (label) with its confidence.
        print("\(classification.identifier): \(percentString) confidence.\n")
        
        let item:[String:Any] = ["audioKey":classification.identifier,"startAt":timeInSeconds,"duration":duration,"confidence":classification.confidence];
        self.analysisResult.append(item);
        
    }
    
    
    /// Notifies the observer when a request generates an error.
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("The the analysis failed: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.callback([[String:Any]]())
        }
    }
    
    /// Notifies the observer when a request is complete.
    func requestDidComplete(_ request: SNRequest) {
        print("The request completed successfully!")
        DispatchQueue.main.async {
            self.callback(self.analysisResult)
        }
    }
}

