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
        let photoState      = PHPhotoLibrary.authorizationStatus()
        
        // MARK: 애플리케이션 처음 진입 시 사진 라이브러리 접근권한이 없다면 사진 라이브러리에 접근 허용 여부를 묻습니다.
        switch photoState {
            case .authorized:                           isAurhorization = true
            case .notDetermined, .restricted, .denied:  isAurhorization = false
            @unknown default:                           isAurhorization = false
        }
        
        // MARK: Not Permission Photos Action
        if isAurhorization == false {
            
            let alert = UIAlertController(title: "Error Not Permission Photos", message: "MyAlbum 애플리케이션을 사용하시기 위해서는 Album 권한이 필요합니다.", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                PHPhotoLibrary.requestAuthorization { status in
                    isAurhorization = (status == .authorized ? true : false)
                }
            }
            
            alert.addAction(confirmAction)
            parent.present(alert, animated: true, completion: nil)
        }
        
        return isAurhorization
    }
}
