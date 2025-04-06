//
//  GearItemUpdate.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//
struct GearUpdate: Codable {
    let currentCondition: String?
    let latitude: Double?
    let longitude: Double?
    let isAvailable: Bool?

    enum CodingKeys: String, CodingKey {
        case currentCondition = "current_condition"
        case latitude
        case longitude
        case isAvailable = "is_available"
    }
}
