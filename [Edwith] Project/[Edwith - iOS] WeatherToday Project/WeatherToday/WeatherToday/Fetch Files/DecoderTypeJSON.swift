//
//  DecoderTypeJSON.swift
//  WeatherToday
//
//  Created by 양창엽 on 13/05/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import Foundation

internal struct CountryType: Decodable {
    
    var nameKorean:     String
    var nameAssert:     String
    
    // MARK: - CodingKey
    private enum CodingKeys: String, CodingKey {
        case nameKorean = "korean_name"
        case nameAssert = "asset_name"
    }
}

internal struct CityType: Decodable {
    
    var nameCity:       String
    var stat:           String
    var celsius:        Double
    var rainfall:       Int
    
    // MARK: - CodingKey
    private enum CodingKeys: String, CodingKey {
        case nameCity = "city_name"
        case stat
        case celsius
        case rainfall = "rainfall_probability"
    }
}
