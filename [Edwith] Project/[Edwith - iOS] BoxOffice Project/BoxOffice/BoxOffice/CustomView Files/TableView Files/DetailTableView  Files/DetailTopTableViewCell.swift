//
//  DetailMovieTopTableViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 09/07/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

// MARK: - Protocol
internal protocol FullScreenPosterGesture {
    func showFullScreenMoviePoster(imageView: UIImageView)
}

class DetailTopTableViewCell: UITableViewCell {

    // MARK: - Outlet Propertise
    @IBOutlet private weak var posterImageView:        UIImageView!
    @IBOutlet private weak var titleLabel:             UILabel!
    @IBOutlet private weak var launchLabel:            UILabel!
    @IBOutlet private weak var typeLabel:              UILabel!
    @IBOutlet private weak var reservationRateLabel:   UILabel!
    @IBOutlet private weak var scoreLabel:             UILabel!
    @IBOutlet private weak var watchPeopleLabel:       UILabel!
    @IBOutlet private weak var ratingView:             StarRatingBar!
    
    // MARK: - Object Propertise
    internal var delegate: FullScreenPosterGesture?
}

// MARK: - Private DetailTopTableViewCell Method
private extension DetailTopTableViewCell {

    func setNumberFormatter(number: Int) -> String? {
        
        let numeric: NSNumber = NSNumber(value: number)
        
        let formatter: NumberFormatter  = NumberFormatter()
        formatter.groupingSeparator     = ","
        formatter.numberStyle           = .decimal
        
        if let result: String = formatter.string(from: numeric) { return result }
        else { return nil }
    }
    
    @objc func showFullScreenMoviePoster() {
        self.delegate?.showFullScreenMoviePoster(imageView: self.posterImageView)
    }
}

// MARK: - Internal DetailTopTableViewCell Method
internal extension DetailTopTableViewCell {
    
    func setMovieDetailViews(_ data: MovieDetailInformation) {
        
        // MARK: UITapGestureRecognizer
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showFullScreenMoviePoster))
        posterImageView.isUserInteractionEnabled = true
        posterImageView.addGestureRecognizer(gesture)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let audience = self.setNumberFormatter(number: data.audience) else { return }
            
            if let image = seperateAgeType(age: data.grade) {
                let title = NSMutableAttributedString(string: "\(data.title) ")
                title.appendImage(image)
                
                self.titleLabel.attributedText = title
            }
            
            self.launchLabel.text              = "\(data.date) 개봉"
            self.typeLabel.text                = "\(data.genre) / \(data.duration)분"
            self.reservationRateLabel.text     = String(format: "%d위 %.2f%%", data.reservationGrade ,data.reservationRate)
            self.scoreLabel.text               = String(format: "%.2f", data.userRating)
            self.watchPeopleLabel.text         = audience
            self.ratingView.score              = CGFloat(data.userRating) / 2.0
        }
        
        Networking.shared.downloadImage(url: data.image, group: DispatchGroup(), imageView: self.posterImageView)
    }
}
