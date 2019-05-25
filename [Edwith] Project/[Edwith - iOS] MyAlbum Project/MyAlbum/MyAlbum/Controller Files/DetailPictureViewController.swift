//
//  DetailPictureViewController.swift
//  MyAlbum
//
//  Created by 양창엽 on 23/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit
import Photos

class DetailPictureViewController: UIViewController {

    // MARK: - Enum
    private enum DetailToolbarItemTag: Int {
        case share = 100
        case like  = 200
        case trash = 300
    }
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var detailPhotoimageView:    UIImageView!
    @IBOutlet private weak var detailPhotoScrollView:   UIScrollView!
    @IBOutlet private weak var featureToolbar:          UIBarButtonItem!
    
    // MARK: - Object Variables
    internal var photoAsset:    PHAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: UIScrollView Delegate
        self.detailPhotoScrollView.delegate = self
        
        // MARK: UITapGestureRecognizer
        let gesture = UITapGestureRecognizer(target: self, action: #selector(touchImageView))
        self.detailPhotoScrollView.addGestureRecognizer(gesture)
        
        // MARK: PHPhotoLibraryChangeObserver
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let asset = self.photoAsset, let currentDate = asset.creationDate else {
            return
        }
        
        setNavigationDate(current: currentDate)
        changeFavoriteTitle(isFavorite: asset.isFavorite)
        
        self.detailPhotoimageView.image = PhotoManager.photoInstance.fetchImagefromPhotoAsset(asset: asset, mode: .aspectFit)
    }
    
    // MARK: - User Method
    private func setNavigationDate(current: Date) {
        
        let formatter = DateFormatter()
        let title: (main: UILabel, sub: UILabel) = (UILabel(frame: CGRect.zero), UILabel(frame: CGRect.zero))
        
        formatter.dateFormat    = "yyyy-MM-dd"
        title.main.text         = formatter.string(from: current)
        title.main.font         = .boldSystemFont(ofSize: 18)
        title.main.sizeToFit()
        
        // MARK: https://stackoverflow.com/questions/31469172/show-am-pm-in-capitals-in-swift
        formatter.dateFormat    = "a hh:mm:ss"
        title.sub.text          = formatter.string(from: current)
        title.sub.textColor     = .darkGray
        title.sub.font          = .systemFont(ofSize: 12)
        title.sub.sizeToFit()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let stackView = UIStackView(arrangedSubviews: [title.main, title.sub])
            stackView.distribution  = .equalCentering
            stackView.axis          = .vertical
            stackView.alignment     = .center
            
            // MARK: https://stackoverflow.com/questions/38626004/add-subtitle-under-the-title-in-navigation-bar-controller-in-xcode/38628080
            self.navigationItem.titleView = stackView
        }
    }
    private func showActivityController(image: UIImage) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    private func trashAssetPhoto() {
        
        guard let asset = self.photoAsset else { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSFastEnumeration)
        }, completionHandler: { success, error in
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                // MARK: 사진을 삭제완료하면 이전 화면으로 되돌아갑니다.
                if success {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        })
    }
    private func favoriteAssetPhoto() {
        
        // MARK: https://developer.apple.com/documentation/photokit/phassetchangerequest
        PHPhotoLibrary.shared().performChanges({ [weak self] in
            guard let self = self, let asset = self.photoAsset else { return }
           
            let request = PHAssetChangeRequest(for: asset)
            request.isFavorite = !asset.isFavorite
            }, completionHandler: { success, _ in
                
                guard success, let asset = self.photoAsset else {
                    return
                }
                
                self.changeFavoriteTitle(isFavorite: asset.isFavorite)
        })
    }
    private func changeFavoriteTitle(isFavorite: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.featureToolbar.title = (isFavorite ? "❤️" : "🖤")
        }
    }
    fileprivate func hiddenNavigationBarAndToolBar(hidden: Bool, touchEvent: Bool) {
        
        if touchEvent == false {
            // MARK: NavigtaionController의 Bar와 ToolBar가 Hidden인 상태에는 함수를 종료한다.
            guard self.navigationController?.isNavigationBarHidden == false else { return }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.navigationController?.setToolbarHidden(hidden, animated: true)
            self.navigationController?.setNavigationBarHidden(hidden, animated: true)
        }
    }
    
    // MARK: - Action Method
    @IBAction private func actionToolbarItems(_ sender: UIBarButtonItem) {
        
        guard let toolbarTag = DetailToolbarItemTag(rawValue: sender.tag) else { return }
        
        switch toolbarTag {
            case .share:
                guard let image = self.detailPhotoimageView.image else { return }
                showActivityController(image: image)
            
            case .like:
                favoriteAssetPhoto()
            
            case .trash:
                trashAssetPhoto()
        }
        
    }
    @objc private func touchImageView() {
        guard let isTouchImage = self.navigationController?.isNavigationBarHidden else { return }
        // MARK: 다시 사진을 터치하면 툴바와 내비게이션바가 나타납니다.
        hiddenNavigationBarAndToolBar(hidden: !isTouchImage, touchEvent: true)
    }
}

// MARK: - UIScrollViewDelegate
extension DetailPictureViewController: UIScrollViewDelegate {
    
    // MARK: viewForZooming(in:) : 스크롤뷰에서 확대 및 축소를 할 때 확대 및 축소를 할 뷰 인스턴스를 요청
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailPhotoimageView
    }
    
    // MARK: scrollViewWillBeginDragging(_:) : 스크롤뷰에서 콘텐츠 스크롤을 시작할 시점을 델리게이트에 알림
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.hiddenNavigationBarAndToolBar(hidden: true, touchEvent: false)
    }
    
    // MARK: scrollViewDidZoom(_:) : 스크롤뷰의 확대 및 축소 배율이 변경될 때 델리게이트에 알림
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.hiddenNavigationBarAndToolBar(hidden: true, touchEvent: false)
    }
}

// MARK: - Extension PHPhotoLibraryChangeObserver
extension DetailPictureViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let asset = self.photoAsset, let changeAsset = changeInstance.changeDetails(for: asset)?.objectAfterChanges else { return }
        // MARK: https://medium.com/@macka/observing-photo-album-changes-ios-swift-23a4c2e741ff
        self.photoAsset = changeAsset
        self.changeFavoriteTitle(isFavorite: changeAsset.isFavorite)
    }
}
