//
//  MovieTableViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - Outlet Variables
    @IBOutlet private weak var presentMovieImageView:       UIImageView!
    @IBOutlet private weak var presentMovieTitleLabel:      UILabel!
    @IBOutlet private weak var presentMovieAgeImageView:    UIImageView!
    @IBOutlet private weak var presentMovieRatingLabel:     UILabel!
    @IBOutlet private weak var presentMovieRankingLabel:    UILabel!
    @IBOutlet private weak var presentMovieRateLabel:       UILabel!
    @IBOutlet private weak var presentMovieLaunchLabel:     UILabel!
    
    // MARK: - User Method
    internal func setPresentMovieData(movieData: MovieList) {
        
        self.presentMovieTitleLabel.text    = movieData.title
        self.presentMovieLaunchLabel.text   = "개봉일 : \(movieData.date)"
        self.presentMovieRatingLabel.text   = "예매순위 : \(movieData.reservationGrade)"
        self.presentMovieRateLabel.text     = "예매율 : \(movieData.reservationRate.rounded())"

        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
