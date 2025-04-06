//
//  ProfileUpdate.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-06.
//

struct ProfileUpdate: Codable {
    let email: String?
    let points: Int?
    let distanceHiked: Int?
    let profilePhotoURL: String?

    enum CodingKeys: String, CodingKey {
        case email
        case points
        case distanceHiked = "distance_hiked"
        case profilePhotoURL = "profile_photo_url"
    }
}
