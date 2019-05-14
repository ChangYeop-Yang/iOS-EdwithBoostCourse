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
    
    // MARK: - CountryType CodingKey
    private enum CodingKeys: String, CodingKey {
        case nameKorean = "korean_name"
        case nameAssert = "asset_name"
    }
}

internal struct CityType: Decodable {
    
    var nameCity:       String
    var state:          Int
    var celsius:        Float32
    var rainfall:       Int
    
    // MARK: - CityType CodingKey
    private enum CodingKeys: String, CodingKey {
        case nameCity = "city_name"
        case state
        case celsius
        case rainfall = "rainfall_probability"
    }
}
