//
//  AuthViewController.swift
//  CryptoTracker
//
//  Created by Vigneshraj Sekar Babu on 6/23/18.
//  Copyright © 2018 Vigneshraj Sekar Babu. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticate()
        
    }
    
    func authenticate() {
        
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Crypto App is secured") { (success, error) in
            if success {
                DispatchQueue.main.async {
                    let cryptoVC = CryptoTableVC()
                    let navigationVC = UINavigationController(rootViewController: cryptoVC)
                    self.present(navigationVC, animated: true, completion: nil)
                }
                
            } else {
                self.authenticate()
            }
        }
    }
    
}
