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
    @IBOutlet private weak var sendBT:              UIButton!
    @IBOutlet private weak var userID:              UITextField!
    @IBOutlet private weak var userTopPassword:     UITextField!
    @IBOutlet private weak var userBottomPassword:  UITextField!
    @IBOutlet private weak var contents:            UITextView!
    @IBOutlet private weak var userImage:           UIImageView!
    
    // MARK: - Variables
    lazy private var information = UserInformation.User()
    fileprivate var isNextStep: (first: Bool, second: Bool, three: Bool, four: Bool) = (false, false, false, false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup UITextField and UITextView Delegate
        setupDelegate()
        
        // SetUp UIImageView GestureRecognizer
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showImagePickerController(sender:)))
        self.userImage.isUserInteractionEnabled = true
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
    }
    private func enableSendButton() {
        self.sendBT.isEnabled = (self.isNextStep.first && self.isNextStep.second && self.isNextStep.three && self.isNextStep.four)
    }
    
    // MARK: - Gesture Recognizer Methods
    @objc func showImagePickerController(sender: UIGestureRecognizer) {
        
        DispatchQueue.main.async { [unowned self] in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }

    // MARK: - Action Methods
    @IBAction private func closeSignUp(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        UserInformation.userInstance.setUserInformation(UserInformation.User())
    }
    @IBAction private func sendSignUp(_ sender: UIButton) {
        
        // MARK: UIImage
        if let image = self.information.userImage {
            UserInformation.userInstance.setImage(image)
        }
        
        // MARK: String
        if let name = self.information.userName, let password = self.information.userPassword, let comments = self.information.userComments {
            UserInformation.userInstance.setUserName(name)
            UserInformation.userInstance.setPassword(password)
            UserInformation.userInstance.setComments(comments)
        }
    }
    
    // MARK: - Event Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
                
                if self.isNextStep.first {
                    self.information.userName = inputText
                }
            
            case .UserPassword:
                if let topPassword = self.userTopPassword.text, let bottomPassword = self.userBottomPassword.text {
                    self.isNextStep.second = UserInformation.userInstance.checkDuplicatePassword(topPassword, bottomPassword)
                    
                    if self.isNextStep.second {
                        self.information.userPassword = inputText
                    }
                }
        }
        
        enableSendButton()
    }
}

// MARK: - UITextViewDelegate Extension
extension SignUpViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.isNextStep.three = textView.text.isEmpty ? false : true
        if self.isNextStep.three { self.information.userComments = textView.text }
        
        enableSendButton()
    }
}

// MARK: - UIImagePickerControllerDelegate Extension
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        /*
            ⌘ UIImagePickerController.InfoKey.editedImage   - 사용자의 수정을 통한 이미지 처리
            ⌘ UIImagePickerController.InfoKey.originalImage - 사용자로 부터 수정없이 이미지 원본 처리
         */
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            self.isNextStep.four = false
            return
        }
        
        self.isNextStep.four = true
        self.userImage.image = image
        self.information.userImage = image
        
        enableSendButton()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
