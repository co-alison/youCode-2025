//
//  GearItem.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import Foundation

struct GearItem: Codable, Identifiable {

    let id: Int?
    let createdAt: Date?
    let name: String
    let type: GearType
    let description: String
    let currentCondition: GearCondition
    let latitude: Double
    let longitude: Double
    let isAvailable: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case name
        case type
        case description
        case currentCondition = "current_condition"
        case latitude
        case longitude
        case isAvailable = "is_available"
    }

    enum GearType: String, CaseIterable, Codable {
        case boots
        case jacket
        case pants
        case hat
        case backpack
        case safety
    }

    enum GearCondition: String, CaseIterable, Codable {
        case poor
        case fair
        case good
        case excellent
    }

    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}
