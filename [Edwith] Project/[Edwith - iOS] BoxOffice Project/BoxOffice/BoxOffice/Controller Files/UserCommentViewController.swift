//
//  UserCommentViewController.swift
//  BoxOffice
//
//  Created by 양창엽 on 23/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class UserCommentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "한줄평 작성"
        self.navigationController?.title = "한줄평 작성"
    }
    
}
