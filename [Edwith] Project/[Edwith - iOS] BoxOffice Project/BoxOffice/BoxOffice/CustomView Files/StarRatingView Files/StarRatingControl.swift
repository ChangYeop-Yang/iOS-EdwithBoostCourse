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
    
    // MARK: - Object Variables
    private var starCount: CGFloat = 5.0
    private var starImageView: [UIImageView] = []
    
    internal var delegate: UpdateStarRatingScore?
    private var imageStars: (empty: UIImage?, half: UIImage?, full: UIImage?) = (
        UIImage(named: "ic_star_large"),
        UIImage(named: "ic_star_large_half"),
        UIImage(named: "ic_star_large_full")
    )
    
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
    
    // MARK: - User Method
    private func setStackView() {
        
        self.distribution = .fillEqually
        
        // MARK: Setting Gesture Recognizer
        let gesturePan = UIPanGestureRecognizer(target: self, action: #selector(setPanGestureRecognizer(_:)))
        self.addGestureRecognizer(gesturePan)
        
        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(setTapGestureRecognizer(_:)))
        self.addGestureRecognizer(gestureTap)
    }
    private func createStarImageView(size: Int) {
        
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
        let rating  = gesture.location(in: self).x / (self.frame.size.width / self.starCount)
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
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
            let front: Int  = Int( rating.rounded() )
            let rear: Float = Float(rating) - Float(front)
            
            // Change All ImageView Empty Star.
            self.starImageView.forEach { view in
                view.image = self.imageStars.empty
            }
            
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
        let rating: CGFloat = gesture.location(in: self).x / (self.frame.size.width / self.starCount)
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            switch rating {
                case -0.5...0:
                    score = 0.0
                    self.starImageView[0].image = self.imageStars.empty
                
                // FIXME: - First Star
                case 0...0.5:
                    score = 0.5
                    self.starImageView[0].image = self.imageStars.half
                case 0.5...1.0:
                    score = 1.0
                    self.starImageView[0].image = self.imageStars.full
                    self.starImageView[1].image = self.imageStars.empty
                
                // FIXME: - Second Star
                case 1.0...1.5:
                    score = 1.5
                    self.starImageView[1].image = self.imageStars.half
                case 1.5...2.0:
                    score = 2.0
                    self.starImageView[1].image = self.imageStars.full
                    self.starImageView[2].image = self.imageStars.empty
                
                // FIXME: - Three Star
                case 2.0...2.5:
                    score = 2.5
                    self.starImageView[2].image = self.imageStars.half
                case 2.5...3.0:
                    score = 3.0
                    self.starImageView[2].image = self.imageStars.full
                    self.starImageView[3].image = self.imageStars.empty
                
                // FIXME: - Four Star
                case 3.0...3.5:
                    score = 3.5
                    self.starImageView[3].image = self.imageStars.half
                case 3.5...4.0:
                    score = 4.0
                    self.starImageView[3].image = self.imageStars.full
                    self.starImageView[4].image = self.imageStars.empty
                
                // FIXME: - Five Star
                case 4.0...4.5:
                    score = 4.5
                    self.starImageView[4].image = self.imageStars.half
                case 4.5...6.0:
                    score = 5.0
                    self.starImageView[4].image = self.imageStars.full
                
                default: break
            }
            
            self.delegate?.updateStarRating(score: score * 2)
        }
    }
}
