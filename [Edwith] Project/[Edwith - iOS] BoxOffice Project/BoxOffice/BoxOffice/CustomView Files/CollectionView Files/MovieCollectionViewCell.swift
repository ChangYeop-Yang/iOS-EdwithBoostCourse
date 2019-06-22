//
//  MovieCollectionViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var moviePosterImageView:    UIImageView!
    @IBOutlet private weak var movieAgeImageView:       UIImageView!
    @IBOutlet private weak var movieTitleLabel:         UILabel!
    @IBOutlet private weak var movieLaunchLabel:        UILabel!
    @IBOutlet private weak var movieRatingLabel:        UILabel!
    
    // MAKR: - User Methods
    internal func setMovieCollectionViewCell(movieData: MovieList) {
        
        // MARK: Setting Movie Information Lable
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.movieTitleLabel.text   = movieData.title
            self.movieRatingLabel.text  = String(format: "%d위(%.2f) / %.2f%%", movieData.reservationGrade, movieData.userRating, movieData.reservationRate)
            self.movieLaunchLabel.text  = movieData.date
            
            seperateAgeType(age: movieData.grade, imageView: self.movieAgeImageView)
        }
        
        // MARK: Setting Movie Image Information ImageView
        let group: DispatchGroup = DispatchGroup()
        Networking.shared.downloadImage(url: movieData.thumb, group: group, imageView: self.moviePosterImageView)
    }
}
