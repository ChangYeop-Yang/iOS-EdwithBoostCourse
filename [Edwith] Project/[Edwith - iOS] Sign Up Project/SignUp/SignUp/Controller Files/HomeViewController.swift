//
//  ViewController.swift
//  SignUp
//
//  Created by 양창엽 on 15/04/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: - Outlet Variables
    @IBOutlet private weak var userID: UITextField!
    @IBOutlet private weak var userIMG: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let information = UserInformation.userInstance.getUserInformation()
        guard let id = information.userName, let image = information.userImage else {
            return
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.userID.text = id
            self.userIMG.image = image
        }
    }
}

