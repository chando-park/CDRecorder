import Foundation
import AVKit

public class CDRecorder: NSObject{
    
    public enum Status{
        case start(success: Bool, errorMessage: String?)
        case end(success: Bool, errorMessage: String?)
    }
    
    public typealias RecordingProcessBlock = (_ status: Status) -> ()
    public typealias RecordPrepareCompletedBlock = (_ isSuccess: Bool, _ errorMessage: String?) -> ()

    private var _audioRecorder: AVAudioRecorder?
    private var _recordSession: AVAudioSession!
    
    private let _audioSetting: [String : Any]
    private let _microphoneNotUsableMessage: String?
    private let _recordingProcessCompltedBlock: RecordingProcessBlock
    
    public init(audioSetting: [String : Any] =
                [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVSampleRateKey: 48000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderBitRateKey: 64000,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ],
                microphoneNotUsableMessage: String? = nil,
                completdBolck: @escaping RecordingProcessBlock) {
        self._audioSetting = audioSetting
        self._microphoneNotUsableMessage = microphoneNotUsableMessage
        self._recordingProcessCompltedBlock = completdBolck
        
        super.init()
    }
    
    public var isRecording: Bool {
        if let _ = self._audioRecorder{
            return true
        }
        return false
    }

    public func prepare(complted: @escaping RecordPrepareCompletedBlock) {
        do {
            self._recordSession = AVAudioSession.sharedInstance()
            self._recordSession.requestRecordPermission() {[unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        do{

                            try self._recordSession.setCategory(AVAudioSession.Category.playAndRecord,
                                                               mode: AVAudioSession.Mode.default,
                                                               options: [.mixWithOthers,.allowBluetooth,.defaultToSpeaker])
                            try self._recordSession.setActive(true)
                            
                            complted(true, nil)
                        }catch let e{
                            complted(false, e.localizedDescription)
                        }
                    } else {
                        complted(false, self._microphoneNotUsableMessage ?? "마이크 권한을 허용해 주세요.")
                    }
                }
            }
        }
    }
    
    public func startRecording(fileUrl: URL, duration: Double){
        do{
            self._audioRecorder = try AVAudioRecorder(url: fileUrl, settings: self._audioSetting)
            self._audioRecorder?.delegate = self
            self._audioRecorder?.record(forDuration: duration)
            
            self._recordingProcessCompltedBlock(.start(success: true, errorMessage: nil))
        }catch let e{
            self.finishRecording()
            
            self._recordingProcessCompltedBlock(.start(success: false, errorMessage: e.localizedDescription))
            
        }
    }

    public func finishRecording(){
        self._audioRecorder?.stop()
        self._audioRecorder = nil
        
        try? self._recordSession?.setActive(false)
    }

}

extension CDRecorder: AVAudioRecorderDelegate{
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self._recordingProcessCompltedBlock(.end(success: true, errorMessage: nil))
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        self._recordingProcessCompltedBlock(.end(success: true, errorMessage: error?.localizedDescription))
    }
}

