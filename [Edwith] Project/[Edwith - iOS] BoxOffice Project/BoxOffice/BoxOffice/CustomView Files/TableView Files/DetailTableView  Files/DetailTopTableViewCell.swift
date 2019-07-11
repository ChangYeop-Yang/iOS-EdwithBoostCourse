//
//  DetailMovieTopTableViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 09/07/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class DetailTopTableViewCell: UITableViewCell {

    // MARK: - Outlet Propertise
    @IBOutlet internal weak var posterImageView:       UIImageView!
    @IBOutlet private weak var titleLabel:             UILabel!
    @IBOutlet private weak var launchLabel:            UILabel!
    @IBOutlet private weak var typeLabel:              UILabel!
    @IBOutlet private weak var reservationRateLabel:   UILabel!
    @IBOutlet private weak var scoreLabel:             UILabel!
    @IBOutlet private weak var watchPeopleLabel:       UILabel!
    @IBOutlet private weak var ratingView:             StarRatingBar!
    
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
}

// MARK: - Internal DetailTopTableViewCell Method
internal extension DetailTopTableViewCell {
    
    func setMovieDetailViews(_ data: MovieDetailInformation) {
        
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
        
        let imageGroup: DispatchGroup = DispatchGroup()
        Networking.shared.downloadImage(url: data.image, group: imageGroup, imageView: self.posterImageView)
    }
}
