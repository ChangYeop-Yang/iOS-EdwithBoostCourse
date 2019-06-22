//
//  UserCommentTableViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 19/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class UserCommentTableViewCell: UITableViewCell {

    // MARK: - Outlet Variables
    @IBOutlet private weak var userNameLabel:           UILabel!
    @IBOutlet private weak var userCreateCommentDate:   UILabel!
    @IBOutlet private weak var userComment:             UILabel!
    
    // MARK: - Object Variables
    internal var movieID: String?
    
    // MARK: - User Methods
    internal func setUserComment(_ data: MovieOneLineList) {
        
        self.movieID = data.movieID
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.userNameLabel.text = data.writer
            self.userComment.text   = data.contents
        }
        
    }
}
