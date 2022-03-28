//
//  ToggleButton.swift
//  Artium Agaora Poc
//
//  Created by Suryavel Tamilselvan Rani on 28/03/22.
//

import Foundation
import UIKit

class ToggleButton: UIButton {
    
    private var isOn = true
    private var onImage:String = ""
    private var offImage:String = ""
    
    var isToggleOn:Bool {
        get {
            return self.isOn
        }
    }

    func toggle() {
        self.isOn = !self.isOn
        
        self.setImageForCurrentState()
        
        tintColor = self.isOn ? nil : UIColor.red
    }
    
    func setImages(_onImage:String, _offImage:String) {
        self.onImage = _onImage
        self.offImage = _offImage
        
        self.setImageForCurrentState()
    }
    
    private func setImageForCurrentState() {
        setImage(UIImage(systemName: self.isOn ? self.onImage : self.offImage), for: .normal)
    }
}
