//
//  StarRatingControl.swift
//  RatingControl
//
//  Created by 양창엽 on 25/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//
import UIKit

@IBDesignable
class StarRatingBar: UIStackView {
    
    // MARK: - Object Variables
    @IBInspectable internal var score: CGFloat = 0.0 {
        willSet (newVal) {
            createStarImageView(count: self.countStar)
            updateStarImageView(score: newVal)
        }
    }
    @IBInspectable internal var countStar: Int = 5 {
        willSet (newVal) {
            createStarImageView(count: newVal)
        }
    }
    private var starImageViews: [UIImageView] = []
    private var imageStars: (empty: UIImage?, half: UIImage?, full: UIImage?) = (
        UIImage(named: "ic_star_large"),
        UIImage(named: "ic_star_large_half"),
        UIImage(named: "ic_star_large_full")
    )
}

// MARK: - Extension
private extension StarRatingBar {
    
    func createStarImageView(count: Int) {
        
        // Clear All Subviews on StackView (초기화 부분)
        clearSubviewsOnStackView()
        
        for _ in 0..<count {
            let view: UIImageView = UIImageView(image: self.imageStars.empty)
            view.contentMode = .scaleAspectFit
            
            self.starImageViews.append(view)
            self.addArrangedSubview(view)
        }
    }
    func updateStarImageView(score: CGFloat) {
        
        let front: Int = Int(score)
        let rear: CGFloat = score - CGFloat(front)
        
        for (index, view) in self.starImageViews.enumerated() where index < front {
            view.image = self.imageStars.full
        }
        
        if rear > 0.0 {
            self.starImageViews[front].image = self.imageStars.half
        }
    }
    func clearSubviewsOnStackView() {
        
        self.starImageViews.removeAll(keepingCapacity: false)
        
        // MARK: https://stackoverflow.com/questions/24312760/how-to-remove-all-subviews-of-a-view-in-swift
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
