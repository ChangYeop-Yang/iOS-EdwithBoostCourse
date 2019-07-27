//
//  StarRatingControl.swift
//  RatingControl
//
//  Created by 양창엽 on 25/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

// MARK: - Protocol
internal protocol UpdateStarRatingScore {
    func updateStarRating(score: CGFloat)
}

class StarRatingControl: UIStackView {
    
    // MARK: - Private Object Propertise
    private var starCount: (float: CGFloat, int: Int) = (5.0, 5)
    private var starImageView: [UIImageView] = []
    private var imageStars: (empty: UIImage?, half: UIImage?, full: UIImage?) = (
        UIImage(named: "ic_star_large"),
        UIImage(named: "ic_star_large_half"),
        UIImage(named: "ic_star_large_full")
    )
    
    // MARK: - Internal Object Propertise
    internal var delegate: UpdateStarRatingScore?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStackView()
        createStarImageView(size: 5)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setStackView()
        createStarImageView(size: 5)
    }
}

// MARK: - Extension
private extension StarRatingControl {
    
    func changeEmptyStarImage() {
        self.starImageView.forEach { view in
            view.image = self.imageStars.empty
        }
    }
    func setStackView() {
        
        self.distribution = .fillEqually
        self.isUserInteractionEnabled = true
        
        // MARK: Setting Gesture Recognizer
        let gesturePan = UIPanGestureRecognizer(target: self, action: #selector(setPanGestureRecognizer(_:)))
        self.addGestureRecognizer(gesturePan)
        
        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(setTapGestureRecognizer(_:)))
        self.addGestureRecognizer(gestureTap)
    }
    func createStarImageView(size: Int) {
        
        self.starImageView.removeAll(keepingCapacity: false)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            for _ in 0..<size {
                let view = UIImageView(image: self.imageStars.empty)
                view.contentMode = .scaleAspectFit
                
                self.starImageView.append(view)
                self.addArrangedSubview(view)
            }
        }
    }
    
    // MARK: - Gesture Recognizer Method
    @objc private func setTapGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        
        var score: CGFloat = 10.0
        let rating  = gesture.location(in: self).x / (self.frame.size.width / self.starCount.float)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Change All ImageView Empty Star.
            self.changeEmptyStarImage()
            
            // MARK: - Upper MaxStarRating Score
            let maxRating: CGFloat = 4.5
            if rating > maxRating {
                // Change All ImageView Full Star.
                self.starImageView.forEach { view in
                    view.image = self.imageStars.full
                }
                
                self.delegate?.updateStarRating(score: score)
                return
            }
            
            // MARK: - Under MaxStarRating Score
            let front: Int  = Int(rating)
            let rear: Float = Float(rating) - Float(front)
            
            score = 0.0
            for (index, view) in self.starImageView.enumerated() where index < front {
                score += 1.0
                view.image = self.imageStars.full
            }
            
            if rear > 0.3 {
                score += 0.5
                self.starImageView[front].image = self.imageStars.half
            }
            
            self.delegate?.updateStarRating(score: score * 2)
        }
    }
    @objc private func setPanGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        
        var score: CGFloat  = 0.0
        let rating: CGFloat = gesture.location(in: self).x / (self.frame.size.width / self.starCount.float)
        
        // MARK: - Under MaxStarRating Score
        let front = Int(rating)
        let rear = Float(rating) - Float(front)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Change All ImageView Empty Star.
            self.changeEmptyStarImage()
            
            if rear > 0.3 && front < self.starCount.int {
                score += 0.5
                self.starImageView[front].image = self.imageStars.half
            }
            
            for (index, view) in self.starImageView.enumerated() where index < front {
                score += 1.0
                view.image = self.imageStars.full
            }
            
            self.delegate?.updateStarRating(score: score * 2)
        }
    }
}
