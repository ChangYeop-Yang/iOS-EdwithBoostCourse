//
//  RatingControl.swift
//  BoxOffice
//
//  Created by 양창엽 on 18/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    // MARK: - Object Variables
    private var ratingButtons: [UIButton]           = []
    private var rating: Int                         = 0 {
        didSet { updateButtonSelectionStates() }
    }
    @IBInspectable private var starSize: CGSize     = CGSize(width: 44.0, height: 44.0) {
        didSet { setupButtons() }
    }
    @IBInspectable private var starCount: Int       = 5 {
        didSet { setupButtons() }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: - Private Methods
    private func setupButtons() {
        
        // Clear Stack View and Button
        for button in self.ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        self.ratingButtons.removeAll()
        
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
            button.setImage(fullStarImage, for: .selected)
            
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
            
            self.ratingButtons.append(button)
            
            /*
             The addArrangedSubview() method adds the button you created to the list of views managed by the RatingControl stack view. This action adds the view as a subview of the RatingControl, and also instructs the RatingControl to create the constraints needed to manage the button’s position within the control.
             */
            self.addArrangedSubview(button)
        }
        
        updateButtonSelectionStates()
    }
    
    // MARK: - Button Action
    @objc private func ratingButtonTapped(button: UIButton) {
        
        guard let index = ratingButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
        }
    }
}
