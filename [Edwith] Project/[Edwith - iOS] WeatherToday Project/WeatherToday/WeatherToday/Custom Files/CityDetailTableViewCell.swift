//
//  CityDetailTableViewCell.swift
//  WeatherToday
//
//  Created by 양창엽 on 14/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class CityDetailTableViewCell: UITableViewCell {
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var nameCityLabel:       UILabel!
    @IBOutlet private weak var rainfallCityLabel:   UILabel!
    @IBOutlet private weak var tempCityLabel:       UILabel!
    @IBOutlet private weak var weatherImageView:    UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - User Method
    internal func setCityWeatherInformation(name: String, temputuer: Float32, rainFall: Int, icon: Int) {
        
        DispatchQueue.main.async { [weak self] in
            self?.nameCityLabel.text        = name
            self?.rainfallCityLabel.text    = "강수확률 \(rainFall) %"
            self?.tempCityLabel.text        = "\(temputuer)"
            
            // MARK: Set Weather Image to UIImageView
            if let tag = WeatherImage(rawValue: icon) {
                
                switch tag {
                    case .cloudy: self?.weatherImageView.image = UIImage(named: "cloudy")
                    case .rainy:  self?.weatherImageView.image = UIImage(named: "rainy")
                    case .snowy:  self?.weatherImageView.image = UIImage(named: "snowy")
                    case .sunny:  self?.weatherImageView.image = UIImage(named: "sunny")
                }
            }
        }
        
    }
}
