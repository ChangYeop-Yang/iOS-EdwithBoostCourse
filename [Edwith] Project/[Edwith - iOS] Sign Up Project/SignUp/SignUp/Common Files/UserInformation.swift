//
//  UserInformation.swift
//  SignUp
//
//  Created by 양창엽 on 16/04/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit
import Foundation

class UserInformation: NSObject {
    
    internal static let userInstance = UserInformation()
    
    // MARK: - Outlet Variables
    private var userName:           String?
    private var userPassword:       String?
    private var userPhoneNumber:    Int?
    private var userImage:          UIImage?
    private var userDate:           Date?
    
    // MARK: - Setter Methods
    internal func setUserName(_ name: String)       { self.userName = name }
    internal func setPassword(_ password: String)   { self.userPassword = password }
    internal func setPhoneNumber(_ phone: Int)      { self.userPhoneNumber = phone }
    internal func setDate(_ date: Date)             { self.userDate = date }
    internal func setImage(_ image: UIImage)        { self.userImage = image }
    
    // MARK: - Getter Methods
    internal func getUserName() -> String?           { return self.userName }
    internal func getPassword() -> String?           { return self.userPassword }
    internal func getUserImage() -> UIImage?         { return self.userImage }
    
    // MARK: - Check Password Method
    internal func checkDuplicatePassword(_ first: String, _ second: String) -> Bool {
        return first.isEmpty || second.isEmpty ? false : first == second
    }
}
