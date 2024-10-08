//
//  PhotoManager.swift
//  MyAlbum
//
//  Created by 양창엽 on 19/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit
import Photos
import Foundation

class PhotoManager: NSObject {
    
    // MARK: - Object Variables
    private let imageManager:           PHCachingImageManager   = PHCachingImageManager()
    internal static let photoInstance:  PhotoManager            = PhotoManager()
    
    // MARK: - System Method
    private override init() {}
    
    // MARK: - User Method
    internal func getImageManager() -> PHCachingImageManager {
        return self.imageManager
    }
    internal func getImageFetchOptions(sortingKey: String, ascending: Bool) -> PHFetchOptions {
        let imagefetchOptions = PHFetchOptions()
        imagefetchOptions.sortDescriptors = [NSSortDescriptor(key: sortingKey, ascending: ascending)]
        
        return imagefetchOptions
    }
    internal func getAurhorizationPhotosState(parent: UIViewController) -> Bool {
        
        var isAurhorization = false
        
        PHPhotoLibrary.requestAuthorization { status in
            // MARK: 애플리케이션 처음 진입 시 사진 라이브러리 접근권한이 없다면 사진 라이브러리에 접근 허용 여부를 묻습니다.
            switch status {
                case .authorized:                           isAurhorization = true
                case .restricted, .denied:                  isAurhorization = false
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization { status in
                        isAurhorization = (status == .authorized ? true : false)
                    }
                @unknown default:                           isAurhorization = false
            }
        }
        
        return isAurhorization
    }
    internal func fetchImagefromPhotoAsset(asset: PHAsset, mode: PHImageContentMode) -> UIImage? {
        
        var image: UIImage?
        let size: CGSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        PhotoManager.photoInstance.getImageManager()
            .requestImage(for: asset, targetSize: size, contentMode: mode, options: nil) { img, _ in
                image = img ?? nil
        }
        
        return image
    }
}
