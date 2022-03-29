//
//  BaseViewController.swift
//  Artium Agaora Poc
//
//  Created by Suryavel Tamilselvan Rani on 29/03/22.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
    }
    
    private func setUpNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "ArtiumLogo"))

        let backButtonItem = UIBarButtonItem()
        backButtonItem.tintColor = UIColor(red: 14 / 255, green: 12 / 255, blue: 119 / 255, alpha: 1)
        navigationItem.backBarButtonItem = backButtonItem

        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .lightGray
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}
