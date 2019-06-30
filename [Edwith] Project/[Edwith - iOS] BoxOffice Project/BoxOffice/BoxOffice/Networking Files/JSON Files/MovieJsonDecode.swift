//
//  MovieJsonDecode.swift
//  BoxOffice
//
//  Created by 양창엽 on 06/06/2019.
//  Copyright © 2019 양창엽. All rights reserved.
//

import Foundation

// MARK: - Decodable

internal struct Movies: Decodable {
    var movies: [MovieList]
}

internal struct Comment: Decodable {
    
    var comments: [MovieOneLineList]
    var movieID: String
    
    // MARK: CountryType CodingKey
    private enum CodingKeys: String, CodingKey {
        case movieID = "movie_id"
        case comments
    }
}

internal struct MovieList: Decodable {
    
    var grade:              Int
    var reservationGrade:   Int
    
    var id:     String
    var title:  String
    var thumb:  String
    var date:   String
    
    var userRating:         Double
    var reservationRate:    Double
    
    // MARK: - CountryType CodingKey
    private enum CodingKeys: String, CodingKey {
        case reservationGrade   = "reservation_grade"
        case reservationRate    = "reservation_rate"
        case userRating         = "user_rating"
        
        case grade, id, title, thumb, date
    }
}

internal struct MovieDetailInformation: Decodable {
    
    var grade:              Int
    var audience:           Int
    var duration:           Int
    var reservationGrade:   Int
    
    var id:         String
    var date:       String
    var title:      String
    var actor:      String
    var director:   String
    var synopsis:   String
    var genre:      String
    var image:      String
    
    var userRating:         Double
    var reservationRate:    Double
    
    // MARK: - CountryType CodingKey
    private enum CodingKeys: String, CodingKey {
        case reservationGrade   = "reservation_grade"
        case reservationRate    = "reservation_rate"
        case userRating         = "user_rating"
        
        case grade, audience, duration, id, date, title, actor, director, synopsis, genre, image
    }
}

internal struct MovieOneLineList: Decodable {
    
    var rating:     Double
    var timestamp:  Double
    
    var writer:     String
    var movieID:    String
    var contents:   String
 
    // MARK: - CountryType CodingKey
    private enum CodingKeys: String, CodingKey {
        case movieID = "movie_id"
        case rating, timestamp, writer, contents
    }
}

// MARK: - Codable

internal struct UserComment: Codable {
    
    var rating:     Double
    
    var writer:     String
    var movieID:    String
    var contents:   String
    
    // MARK: - CountryType CodingKey
    private enum CodingKeys: String, CodingKey {
        case movieID = "movie_id"
        case rating, writer, contents
    }
}
