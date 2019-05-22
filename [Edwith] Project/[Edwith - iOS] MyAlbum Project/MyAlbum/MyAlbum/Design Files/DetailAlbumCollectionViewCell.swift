//
//  DetailAlbumCollectionViewCell.swift
//  MyAlbum
//
//  Created by 양창엽 on 21/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class DetailAlbumCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var detailAlbumImageView: RoundImageView!
    
    // MARK: - User Method
    internal func setImageView(image: UIImage) {
        self.detailAlbumImageView.image = image
    }
    internal func getImages() -> UIImage? {
        return self.detailAlbumImageView.image
    }
}
