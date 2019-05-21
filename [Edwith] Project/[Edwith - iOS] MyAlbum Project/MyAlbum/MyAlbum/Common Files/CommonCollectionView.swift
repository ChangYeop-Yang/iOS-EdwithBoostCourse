//
//  CommonCollectionView.swift
//  MyAlbum
//
//  Created by 양창엽 on 22/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

internal func setFlowLayoutCollectionView(_ collectionView: UICollectionView) {
    let flowlayout = UICollectionViewFlowLayout()
    flowlayout.sectionInset = UIEdgeInsets.init(top: 20, left: 10, bottom: 20, right: 10)
    collectionView.collectionViewLayout = flowlayout
}
