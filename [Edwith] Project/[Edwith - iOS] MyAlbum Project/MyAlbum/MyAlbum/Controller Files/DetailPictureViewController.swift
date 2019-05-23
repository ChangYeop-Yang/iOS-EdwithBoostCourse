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
    @IBOutlet private weak var detailPhotoimageView: UIImageView!
    
    // MARK: - Object Variables
    internal var photoAsset: PHAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let asset = self.photoAsset else { return }
            
            if let image = PhotoManager.photoInstance.fetchImagefromPhotoAsset(asset: asset) {
                self.detailPhotoimageView.image = image
            }
        
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy-MM-dd"
            
            self.title = formatter.string(from: asset.creationDate!)
            print(formatter.string(from: asset.creationDate!))
        }
    }
    
    // MARK: - User Method
    
    // MARK: - Action Method
    @IBAction func actionToolbarItems(_ sender: UIBarButtonItem) {
        
        guard let toolbarTag = DetailToolbarItemTag(rawValue: sender.tag) else { return }
        
        switch toolbarTag {
            case .share: break
            
            
            case .like: break
            
            
            case .trash: break
            
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
