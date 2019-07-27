//
//  UserCommentTableViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 19/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class UserCommentViewCell: UITableViewCell {

    // MARK: - Outlet Propertise
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var userCreateCommentDate: UILabel!
    @IBOutlet private weak var userCommentLabel: UILabel!
    @IBOutlet private weak var userRatingStarBar: StarRatingBar!
    
    // MARK: - Object Propertise
    internal var movieID: String?
    
    // MARK: - System Method
    override func prepareForReuse() {
        super.prepareForReuse()
        
        clearCellSubview()
    }
}

// MARK: - Extension UserCommentViewCell Delegate
internal extension UserCommentViewCell {
    
    func setUserComment(_ data: MovieOneLineList) {
        
        self.movieID = data.movieID
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        
        let date = Date(timeIntervalSince1970: data.timestamp)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.userNameLabel.text     = data.writer
            self.userCommentLabel.text  = data.contents
            
            self.userCreateCommentDate.text = formatter.string(from: date)
            
            self.userRatingStarBar.score = CGFloat(data.rating) / 2.0
            
            self.layoutIfNeeded()
        }
    }
    func clearCellSubview() {
        self.userNameLabel.text = nil
        self.userCommentLabel.text = nil
        self.userCreateCommentDate.text = nil
        
        self.userRatingStarBar.score = 0.0
    }
}
