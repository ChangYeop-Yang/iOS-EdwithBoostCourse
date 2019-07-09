//
//  DetailActorAndDirectorTableViewCell.swift
//  BoxOffice
//
//  Created by 양창엽 on 09/07/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class DetailActorAndDirectorCell: UITableViewCell {

    // MARK: - Object Propertise
    @IBOutlet private weak var actorLable:     UILabel!
    @IBOutlet private weak var directorLabel:  UILabel!
}

// MARK: - Internal Extension DetailActorAndDirectorTableViewCell Method
internal extension DetailActorAndDirectorCell {
    
    func setActorAndDirectorView(actor: String, director: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.actorLable.text = actor
            self.directorLabel.text = director
        }
    }
}
