//
//  ViewController.swift
//  Artium Agaora Poc
//
//  Created by Suryavel Tamilselvan Rani on 28/03/22.
//

import UIKit
import AgoraRtcKit
import Alamofire

class CallViewController: BaseViewController, AgoraRtcEngineDelegate {
    
    @IBOutlet var remoteView:UIView!
    @IBOutlet var localView:UIView!
    
    @IBOutlet var micButton:ToggleButton!
    @IBOutlet var cameraButton:ToggleButton!
    @IBOutlet var peopleButton:ToggleButton!
    @IBOutlet var disconnectButton:ToggleButton!
    
    @IBOutlet var remoteMicIndicator:UIImageView!
    @IBOutlet var remoteCameraIndicator:UIImageView!
    
    var channelInfo:ChannelInfo? = nil
    
    var agoraKit: AgoraRtcEngineKit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        micButton.setImages(_onImage: "mic", _offImage: "mic.slash")
        cameraButton.setImages(_onImage: "video", _offImage: "video.slash")
        
        remoteCameraIndicator.tintColor = UIColor.green
        remoteMicIndicator.tintColor = UIColor.green
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let cInfo = channelInfo {
            self.initializeAndJoinChannel(appId: cInfo.appId, channelId: cInfo.channelName, token: cInfo.token)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didAudioMuted muted: Bool, byUid uid: UInt) {
        remoteMicIndicator.tintColor = muted ? UIColor.red : UIColor.green
        remoteMicIndicator.image =  UIImage(systemName: muted ? "mic.slash.fill" : "mic.fill")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted: Bool, byUid uid: UInt) {
        remoteCameraIndicator.tintColor = muted ? UIColor.red : UIColor.green
        remoteCameraIndicator.image =  UIImage(systemName: muted ? "video.slash.fill" : "video.fill")
    }
    
    deinit {
        agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }
}

extension CallViewController {
    
    @IBAction func onCallControll(view:UIView) {
        switch view {
        case micButton:
            toggleMic()
        case cameraButton:
            toggleCamera()
        case disconnectButton:
            disconnectFromCall()
        default:
            break;
        }
    }
    
    private func toggleMic() {
        micButton.toggle()
        
        agoraKit?.muteLocalAudioStream(!micButton.isToggleOn)
    }
    
    private func toggleCamera() {
        cameraButton.toggle()
        
        agoraKit?.muteLocalVideoStream(!cameraButton.isToggleOn)
    }
    
    private func disconnectFromCall() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CallViewController {
    private func initializeAndJoinChannel(appId:String, channelId:String, token:String) {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId:appId , delegate: self)
        
        agoraKit?.setChannelProfile(.liveBroadcasting)
        
        agoraKit?.setClientRole(.broadcaster)
        
        agoraKit?.enableVideo()
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        agoraKit?.setupLocalVideo(videoCanvas)
        
        agoraKit?.joinChannel(byToken: token, channelId:channelId , info: nil, uid: 0, joinSuccess: { _, _, _ in
            print("Joined the channel successfully ")
        })
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        updateRemote(uid: uid)
    }
    
    private func updateRemote(uid:UInt) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = remoteView
        agoraKit?.setupRemoteVideo(videoCanvas)
        view.bringSubviewToFront(localView)
    }
}

struct ChannelInfo: Decodable {
    let appId:String
    let channelName:String
    let token:String
}
