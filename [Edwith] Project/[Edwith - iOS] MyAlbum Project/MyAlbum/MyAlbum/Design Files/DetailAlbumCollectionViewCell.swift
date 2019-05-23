//
//  DetailAlbumCollectionViewCell.swift
//  MyAlbum
//
//  Created by 양창엽 on 21/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit
import Photos

class DetailAlbumCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var detailAlbumImageView:    RoundImageView!
    @IBOutlet private weak var frontCoverView:          UIView!
    
    // MARK: - Variables
    private var fetchAsset: PHAsset?
    
    // MARK: - User Method
    internal func setImageView(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.detailAlbumImageView.image = image
        }
    }
    internal func setFetchAsset(asset: PHAsset) {
        self.fetchAsset = asset
    }
    internal func getImages() -> UIImage? {
        return self.detailAlbumImageView.image
    }
    internal func getFetchAsset() -> PHAsset? {
        return self.fetchAsset
    }
    internal func getFrontCoverView() -> UIView {
        return self.frontCoverView
    }
}
