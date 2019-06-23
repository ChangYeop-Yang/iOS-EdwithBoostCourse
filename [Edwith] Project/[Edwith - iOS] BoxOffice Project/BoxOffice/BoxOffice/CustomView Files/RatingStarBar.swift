//
//  RatingStarBar.swift
//  BoxOffice
//
//  Created by 양창엽 on 18/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class RatingStarBar: UIStackView {
    
    // MARK: - Object Variables
    internal var rating: Double                     = 0.0 {
        didSet { updateButtonSelectionStates() }
    }
    private var ratingButtons: [UIButton]           = []
    private var starSize: CGSize                    = CGSize(width: 24, height: 24)
    private var starCount: Int                      = 5

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }

    // MARK: - User Methods
    private func setupButtons() {
        
        // Load Button Images
        let bundle          = Bundle(for: type(of: self))
        let fullStarImage   = UIImage(named: "ic_star_large_full", in: bundle, compatibleWith: self.traitCollection)
        let emptyStarImage  = UIImage(named: "ic_star_large", in: bundle, compatibleWith: self.traitCollection)
        let halfStarImage   = UIImage(named: "ic_star_large_half", in: bundle, compatibleWith: self.traitCollection)
        
        // MARK: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ImplementingACustomControl.html
        for _ in 0..<self.starCount {
            
            let button = UIButton()
            
            // MARK: Button Constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: self.starSize.height).isActive  = true
            button.widthAnchor.constraint(equalToConstant: self.starSize.width).isActive    = true
            
            // MARK: Set the button images
            button.setImage(emptyStarImage, for: .normal)
            button.setImage(fullStarImage,  for: .selected)
            button.setImage(halfStarImage,  for: .highlighted)
            
            self.ratingButtons.append(button)
            
            /*
             The addArrangedSubview() method adds the button you created to the list of views managed by the RatingControl stack view. This action adds the view as a subview of the RatingControl, and also instructs the RatingControl to create the constraints needed to manage the button’s position within the control.
             */
            self.addArrangedSubview(button)
        }
        
        //updateButtonSelectionStates()
    }
    private func updateButtonSelectionStates() {
        
        let rate: Double = self.rating / 2.0
        
        for (index, button) in self.ratingButtons.enumerated() {
            if index + 1 < Int( ceil(rate) ) {
                button.isSelected = true
                continue
            }
            
            if ceil(rate) - rate > 0.0 {
                button.isHighlighted = true
                break
            }
        }
    }
}
