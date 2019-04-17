//
//  DetailSignUpViewController.swift
//  SignUp
//
//  Created by 양창엽 on 17/04/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class DetailSignUpViewController: UIViewController {

    // MARK: - Outlet Variables
    @IBOutlet private weak var userDate: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var sendBT: UIButton!
    @IBOutlet private weak var userTel: UITextField!
    
    // MARK: - Variables
    private var dateFormatter = DateFormatter()
    private var isEnabled: (first: Bool, second: Bool) = (false, false)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userTel.delegate = self
        self.dateFormatter.dateStyle = .medium
        self.datePicker.addTarget(self, action: #selector(changeDateValue), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let information = UserInformation.userInstance.getUserInformation()
        guard let date = information.userDate, let tel = information.userPhoneNumber else {
            return
        }
        
        self.sendBT.isEnabled = true
        
        DispatchQueue.main.async { [unowned self] in
            self.userTel.text = tel
            self.datePicker.date = date
            
            self.userDate.text  = self.dateFormatter.string(from: date)
            self.userTel.text   = tel
        }
    }
    
    // MARK: - User Methods
    private func enableSendButton() {
        self.sendBT.isEnabled = self.isEnabled.first && self.isEnabled.second
    }
    
    @objc private func changeDateValue() {
        
        DispatchQueue.main.async { [unowned self] in
            self.isEnabled.second = true
            self.enableSendButton()
            
            UserInformation.userInstance.setDate(self.datePicker.date)
            self.userDate.text = self.dateFormatter.string(from: self.datePicker.date)
        }
    }
    
    // MARK: - Action Methods
    @IBAction func controlButton(_ sender: UIButton) {
        
        guard let tag = TagButton(rawValue: sender.tag) else {
            print("❌ Error, Not could get TagButton.")
            return
        }
        
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Main")
        
        switch tag
        {
            case .Cancel:
                self.present(mainVC, animated: true, completion: nil)
                UserInformation.userInstance.setUserInformation(UserInformation.User())
            
            case .Privious:
                self.dismiss(animated: true, completion: nil)
            
            case .Sign:
                self.present(mainVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UITextFieldDelegate Extension
extension DetailSignUpViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let inputText = textField.text else {
            self.isEnabled.first = false
            return
        }
        
        self.isEnabled.first = true
        UserInformation.userInstance.setPhoneNumber(inputText)
        
        enableSendButton()
    }
}