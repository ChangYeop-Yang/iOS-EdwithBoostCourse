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
    @IBOutlet private weak var userDate:        UILabel!
    @IBOutlet private weak var datePicker:      UIDatePicker!
    @IBOutlet private weak var sendBT:          UIButton!
    @IBOutlet private weak var userTel:         UITextField!
    
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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.userTel.text       = tel
            self.datePicker.date    = date
            self.userDate.text      = self.dateFormatter.string(from: date)
        }
    }
    
    // MARK: - User Methods
    private func enableSendButton() {
        self.sendBT.isEnabled = self.isEnabled.first && self.isEnabled.second
    }
    
    @objc private func changeDateValue() {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
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
                self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - Event Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate Extension
extension DetailSignUpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let inputText = textField.text else {
            self.isEnabled.first = false
            return self.isEnabled.first
        }
        
        self.isEnabled.first = true
        UserInformation.userInstance.setPhoneNumber(inputText)
        
        enableSendButton()
        
        return self.isEnabled.first
    }
}
