//
//  UserCommentTableViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 19/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit



class UserCommentViewCell: UITableViewCell {

    // MARK: - Outlet Variables
    @IBOutlet private weak var userNameLabel:           UILabel!
    @IBOutlet private weak var userCreateCommentDate:   UILabel!
    @IBOutlet private weak var userCommentLabel:        UILabel!
    @IBOutlet private weak var userRatingStarBar:       StarRatingBar!
    
    // MARK: - Object Variables
    internal var movieID: String?
    
    // MARK: - System Method
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.userNameLabel.text = ""
        self.userCreateCommentDate.text = ""
        self.userCommentLabel.text = ""
        self.userRatingStarBar.score = 0.0
    }
    
    // MARK: - User Method
    internal func setUserComment(_ data: MovieOneLineList) {
        
        self.movieID = data.movieID
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.userNameLabel.text = data.writer
            self.userCommentLabel.text = data.contents

            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
            
            let date = Date(timeIntervalSince1970: data.timestamp)
            self.userCreateCommentDate.text = formatter.string(from: date)
            
            self.userRatingStarBar.score = CGFloat(data.rating) / 2.0
        }
    }
}
