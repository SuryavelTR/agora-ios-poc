//
//  ViewController.swift
//  Artium Agaora Poc
//
//  Created by Suryavel Tamilselvan Rani on 28/03/22.
//

import UIKit
import AgoraRtcKit
import Alamofire

class ViewController: UIViewController, AgoraRtcEngineDelegate {
    
    @IBOutlet var remoteView:UIView!
    @IBOutlet var localView:UIView!
    
    @IBOutlet var micButton:ToggleButton!
    @IBOutlet var cameraButton:ToggleButton!
    @IBOutlet var peopleButton:ToggleButton!
    @IBOutlet var disconnectButton:ToggleButton!
    
    @IBOutlet var remoteMicIndicator:UIImageView!
    @IBOutlet var remoteCameraIndicator:UIImageView!
    
    var agoraKit: AgoraRtcEngineKit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        micButton.setImages(_onImage: "mic", _offImage: "mic.slash")
        cameraButton.setImages(_onImage: "video", _offImage: "video.slash")
        
        remoteCameraIndicator.tintColor = UIColor.green
        remoteMicIndicator.tintColor = UIColor.green
        
        //        initializeAndJoinChannel(appId: "f2b6d3398e0d42418815bee3b7974e5f", channelId: "artium_demo_ch", token: "006f2b6d3398e0d42418815bee3b7974e5fIAAsXz6DxcbVGMDDD1kmyLQflHNyE8zgAJsG+OiUGQhLHBEfIGgAAAAAEAAJmhJvr6JCYgEAAQCuokJi")
        
        fetchChannelInfo { channelInfo in
            self.initializeAndJoinChannel(appId: channelInfo.appId, channelId: channelInfo.channelName, token: channelInfo.token)
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

extension ViewController {
    
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

extension ViewController {
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

extension ViewController {
    
    func fetchChannelInfo(onSuccess:@escaping (ChannelInfo)->Void) {
        AF.request(
            "https://a1d4068a-0222-49d7-bd1e-1699debeccca.mock.pstmn.io/api/v1/agora-poc/call-info",
            method: .get).responseDecodable(of: ChannelInfo.self) { response in
                if let channelInfo = response.value {
                    onSuccess(channelInfo)
                }
            }
    }
}

struct ChannelInfo: Decodable {
    let appId:String
    let channelName:String
    let token:String
}
