//
//  Profile.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import Foundation

struct Profile: Codable {
    
    let id: UUID
    let email: String
    let firstName: String
    let lastName: String
    let points: Int? = 0
    let distanceHiked: Int? = 0
    let elevationGained: Int? = 0
    let created_at: Date? = Date()
    let profilePhotoURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case points
        case distanceHiked = "distance_hiked"
        case elevationGained = "elevation_gained"
        case created_at = "created_at"
        case profilePhotoURL = "profile_photo_url"
    }
    
    
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}


