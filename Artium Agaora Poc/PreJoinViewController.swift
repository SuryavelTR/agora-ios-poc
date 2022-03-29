//
//  PreJoinViewController.swift
//  Artium Agaora Poc
//
//  Created by Suryavel Tamilselvan Rani on 29/03/22.
//

import Foundation
import UIKit
import Alamofire

class PreJoinViewController : BaseViewController {
    @IBOutlet var joinButton:UIView!
    @IBOutlet var progressIndicatorView:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressIndicatorView.isHidden = true
    }
    
    @IBAction func onJoinAction() {
        joinButton.isHidden = true
        progressIndicatorView.isHidden = false
        progressIndicatorView.startAnimating()
        fetchChannelInfo { channelInfo in
            self.progressIndicatorView.stopAnimating()
            self.joinButton.isHidden = false
            self.progressIndicatorView.isHidden = true
            if let callViewController = self.storyboard?.instantiateViewController(withIdentifier: "callViewController") as? CallViewController {
                callViewController.channelInfo = channelInfo
                self.navigationController?.pushViewController(callViewController, animated: true)
            }
        }
    }
    
    func fetchChannelInfo(onSuccess:@escaping (ChannelInfo)->Void) {
        AF.request(
            "https://62417a609b450ae27440813c.mockapi.io/api/v1/agora-poc/call-info",
            method: .get).responseDecodable(of: ChannelInfo.self) { response in
                if let channelInfo = response.value {
                    onSuccess(channelInfo)
                }
            }
    }
}
