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
    @IBOutlet private weak var contents: UITextView!
    @IBOutlet private weak var userImage: UIImageView!
    
    // MARK: - Variables
    private var imagePicker: UIImagePickerController = UIImagePickerController()
    fileprivate var isNextStep: (first: Bool, second: Bool, three: Bool, four: Bool) = (false, false, false, false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup UITextField and UITextView Delegate
        setupDelegate()
        
        // Setup Gesture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTapGesture(_:)))
        self.userImage.addGestureRecognizer(gesture)
    }
    
    // MARK: - User Methods
    private func setupDelegate() {
        // MARK: UITextField Delegate
        self.userID.delegate = self
        self.userTopPassword.delegate = self
        self.userBottomPassword.delegate = self
        
        // MARK: UITextView Delegate
        self.contents.delegate = self
        
        // MARK: UIImagePickerController Deleagate
        self.imagePicker.sourceType = .photoLibrary
    }
    private func enableSendButton() {
        self.sendBT.isEnabled = (self.isNextStep.first && self.isNextStep.second && self.isNextStep.three && self.isNextStep.four)
    }
    
    // MARK: - Gesture Recognizer Methods
    @objc func imageTapGesture(_ sender: UITapGestureRecognizer) {
        switch sender.state {
            case .ended:
                self.present(self.imagePicker, animated: true, completion: nil)
            
            default: break
        }
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
        
        guard let tag = TagTextField(rawValue: textField.tag), let inputText = textField.text else {
            print("❌ Error, Not could get TagTextField and TextField Text.")
            return
        }
        
        switch tag {
            case .UserID:
                self.isNextStep.first = inputText.isEmpty ? false : true
                if self.isNextStep.first { UserInformation.userInstance.setUserName(inputText) }
            
            case .UserPassword:
                self.isNextStep.second = UserInformation.userInstance.checkDuplicatePassword(self.userTopPassword.text!, self.userBottomPassword.text!)
                if self.isNextStep.second { UserInformation.userInstance.setPassword(inputText) }
        }
        
        enableSendButton()
    }
}

// MARK: - UITextViewDelegate Extension
extension SignUpViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.isNextStep.three = textView.text.isEmpty ? false : true
        setupDelegate()
    }
}

// MARK: - UIImagePickerControllerDelegate Extension
extension SignUpViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            self.isNextStep.four = false
            return
        }
        
        self.isNextStep.four = true
        UserInformation.userInstance.setImage(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
