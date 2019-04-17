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
    
    // MARK: - Struture
    internal struct User {
        var userName:           String?
        var userPassword:       String?
        var userComments:       String?
        var userPhoneNumber:    String?
        var userImage:          UIImage?
        var userDate:           Date?
    }
    
    // MARK: - Outlet Variables
    private var userInformation = User()
    
    // MARK: - Setter Methods
    internal func setUserInformation(_ user: User)  { self.userInformation = user }
    internal func setUserName(_ name: String)       { self.userInformation.userName = name }
    internal func setPassword(_ password: String)   { self.userInformation.userPassword = password }
    internal func setPhoneNumber(_ phone: String)   { self.userInformation.userPhoneNumber = phone }
    internal func setDate(_ date: Date)             { self.userInformation.userDate = date }
    internal func setImage(_ image: UIImage)        { self.userInformation.userImage = image }
    internal func setComments(_ comments: String)   { self.userInformation.userComments = comments }
    
    // MARK: - Getter Methods
    internal func getUserInformation() -> User      { return self.userInformation }
    
    // MARK: - Check Password Method
    internal func checkDuplicatePassword(_ first: String, _ second: String) -> Bool {
        return first.isEmpty || second.isEmpty ? false : first == second
    }
}
