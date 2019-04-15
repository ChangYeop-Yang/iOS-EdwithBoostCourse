//
//  SignUpViewController.swift
//  SignUp
//
//  Created by 양창엽 on 16/04/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var sendBT: UIButton!
    @IBOutlet private weak var userID: UITextField!
    @IBOutlet private weak var userTopPassword: UITextField!
    @IBOutlet private weak var userBottomPassword: UITextField!
    
    // MARK: - Variables
    fileprivate var isNextStep: (first: Bool, second: Bool) = (false, false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTextField()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - User Methods
    private func setupTextField() {
        self.userID.delegate = self
        self.userTopPassword.delegate = self
        self.userBottomPassword.delegate = self
    }
    
    // MARK: - Action Methods
    @IBAction private func closeSignUp(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func sendSignUp(_ sender: UIButton) {
    }
}

// MARK: - UITextFieldDelegate Extension
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let tag = TagTextField(rawValue: textField.tag) else {
            return
        }
        
        if let inputText = textField.text {
            switch tag {
                case .UserID:
                    isNextStep.first = true
                    UserInformation.userInstance.setUserName(inputText)
                
                case .UserPassword:
                    isNextStep.second = UserInformation.userInstance.checkDuplicatePassword(self.userTopPassword.text!, self.userBottomPassword.text!)
            }
            
            self.sendBT.isEnabled = isNextStep.first && isNextStep.second ? true : false
        }
    }
}
