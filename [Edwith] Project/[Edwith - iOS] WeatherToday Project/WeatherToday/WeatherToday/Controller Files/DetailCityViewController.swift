//
//  DetailCityViewController.swift
//  WeatherToday
//
//  Created by 양창엽 on 14/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import UIKit

class DetailCityViewController: UIViewController {
    
    // MARK: - Outlet Variables
    @IBOutlet private weak var weatherimageView:        UIImageView!
    @IBOutlet private weak var weatherStateLabel:       UILabel!
    @IBOutlet private weak var watherTemputerLabel:     UILabel!
    @IBOutlet private weak var weatherRainfallLabel:    UILabel!
    
    // MARK: - Variables
    internal var cityInformation: CityType?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = cityInformation?.nameCity
        
        if let inf = cityInformation {
            setCityInformation(rainFall: inf.rainfall, temputuer: inf.celsius, icon: inf.state)
        }
    }
    
    // MARK: - User Method
    private func setCityInformation(rainFall: Int, temputuer: Float32, icon: Int) {
        
        self.weatherRainfallLabel.text           = "강수확률 \(rainFall) %"
        self.weatherRainfallLabel.textColor      = (rainFall < 60 ? UIColor.black : UIColor.orange)
        
        let fahrenheit                           = (temputuer * 9/5) + 32
        self.watherTemputerLabel.text            = String(format: "섭씨 %.1f도 / 화씨 %.1f도", temputuer, fahrenheit)
        self.watherTemputerLabel.textColor       = (temputuer > 10 ? UIColor.black : UIColor.blue)
        
        // MARK: Set Weather Image to UIImageView
        if let tag = WeatherImage(rawValue: icon) {
            
            switch tag {
                case .cloudy:
                    self.weatherStateLabel.text = "흐림"
                    self.weatherimageView.image = UIImage(named: "cloudy")
                case .rainy:
                    self.weatherStateLabel.text = "비"
                    self.weatherimageView.image = UIImage(named: "rainy")
                case .snowy:
                    self.weatherStateLabel.text = "눈"
                    self.weatherimageView.image = UIImage(named: "snowy")
                case .sunny:
                    self.weatherStateLabel.text = "맑음"
                    self.weatherimageView.image = UIImage(named: "sunny")
            }
        }
        
    }
}
