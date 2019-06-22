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
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // MARK: Setting Movie Information Label
            self.presentMovieTitleLabel.text    = movieData.title
            self.presentMovieLaunchLabel.text   = "개봉일 : \(movieData.date)"
            self.presentMovieRatingLabel.text   = String(format: "평점 : %.2f", movieData.userRating)
            self.presentMovieRankingLabel.text  = "예매순위 : \(movieData.reservationGrade)"
            self.presentMovieRateLabel.text     = String(format: "예매율 : %.2f", movieData.reservationRate)
            
            seperateAgeType(age: movieData.grade, imageView: self.presentMovieAgeImageView)
        }
        
        // MARK: Setting Movie Image Information Label
        let group: DispatchGroup = DispatchGroup()
        Networking.shared.downloadImage(url: movieData.thumb, group: group, imageView: self.presentMovieImageView)
    }
}
