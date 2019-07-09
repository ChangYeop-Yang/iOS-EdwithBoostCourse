//
//  DetailTableViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 09/07/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class DetailOutlineCell: UITableViewCell {

    // MARK: - Object Propertise
    @IBOutlet private weak var outlineTextView: UITextView!
}

// MARK: - Internal DetailOutlineTableViewCell Method
internal extension DetailOutlineCell {
    
    func setMovieOutlineView(_ synopsis: String) {
    
        DispatchQueue.main.async { [weak self] in
            self?.outlineTextView.text = synopsis
        }
    }
}
