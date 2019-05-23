//
//  RepresentAlbumCollectionViewCell.swift
//  MyAlbum
//
//  Created by 양창엽 on 19/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class RepresentAlbumCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var representPhotoImageView:     UIImageView!
    @IBOutlet private weak var representPhotoTitleLabel:    UILabel!
    @IBOutlet private weak var representPhotoCountLabel:    UILabel!
    
    // MARK: - User Method
    internal func setRepresentPhotoOutlets(image: UIImage, title: String, count: Int) {
            representPhotoImageView.image = image
            representPhotoTitleLabel.text = title
            representPhotoCountLabel.text = String.init(format: "%d", count)
    }
}
