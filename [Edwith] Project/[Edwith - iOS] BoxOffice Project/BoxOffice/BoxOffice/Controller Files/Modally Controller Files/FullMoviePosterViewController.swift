//
//  FullMoviePosterViewController.swift
//  BoxOffice
//
//  Created by 양창엽 on 23/07/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class FullMoviePosterViewController: UIViewController {
    
    // MARK: - Outlet Propertise
    @IBOutlet private weak var fullMoviePosterImageView: UIImageView!
    @IBOutlet private weak var closeModalButton: UIButton!
    
    // MARK: - Object Propertise
    internal var image: UIImage?

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let img = self.image {
            self.fullMoviePosterImageView.image = img
        }
    }
}

// MARK: - Private Extension FullMoviePosterViewController
private extension FullMoviePosterViewController {
    
    @IBAction func closeViewController(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
}
