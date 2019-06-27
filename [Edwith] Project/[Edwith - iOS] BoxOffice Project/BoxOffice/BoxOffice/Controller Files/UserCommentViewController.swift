//
//  UserCommentViewController.swift
//  BoxOffice
//
//  Created by 양창엽 on 23/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class UserCommentViewController: UIViewController {
    
    // MARK: - Enum
    private enum NavigationItemTag: Int {
        case left   = 1000
        case right  = 2000
    }
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var movieNameLabel:          UILabel!
    @IBOutlet private weak var movieAgeImageView:       UIImageView!
    @IBOutlet private weak var movieUserRatingLabel:    UILabel!
    @IBOutlet private weak var movieUserRatingBar:      StarRatingControl!
    
    // MARK: - Object Variables
    internal var informationMovie: (name: String, id: String, age: Int)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.movieUserRatingBar.delegate = self
        
        // MARK:
        createNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self ,let information = self.informationMovie else { return }
            
            self.movieNameLabel.text = information.name
            seperateAgeType(age: information.age, imageView: self.movieAgeImageView)
        }
        
    }
    
    // MARK: - User Methods
    private func createNavigationItem() {
        
        self.title = "한줄평 작성"
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // Left UIBarButton Item
        let left = UIBarButtonItem.init(title: "취소"
            , style: .done
            , target: self
            , action: #selector(actionNavigationItems(_:)) )
        left.tag = NavigationItemTag.left.rawValue
        
        // Right UIBarButton Item
        let right = UIBarButtonItem.init(title: "완료"
            , style: .plain
            , target: self
            , action: #selector(actionNavigationItems(_:)) )
        right.tag = NavigationItemTag.right.rawValue
        
        self.navigationItem.leftBarButtonItem   = left
        self.navigationItem.rightBarButtonItem  = right
    }
    @objc private func actionNavigationItems(_ item: UIBarButtonItem) {
        
        guard let tag = NavigationItemTag(rawValue: item.tag) else { return }
        
        switch tag {
            case .left:
                self.navigationController?.popViewController(animated: true)
            case .right:
                break
        }
    }
}

// MARK: - Extension UpdateStarRatingScore
extension UserCommentViewController: UpdateStarRatingScore {
    
    func updateStarRating(score: CGFloat) {
        let value = score.rounded()
        self.movieUserRatingLabel.text = String(format: "%d", Int(value) )
    }
}
