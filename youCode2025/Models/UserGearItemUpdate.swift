//
//  UserGearItemUpdate.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-06.
//

struct UserGearItemUpdate: Codable {
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case isActive = "is_active"
    }
}
