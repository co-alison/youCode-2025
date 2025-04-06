//
//  UserGearLink.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//
import Foundation

struct UserGearLink: Codable {
    let userGearId: Int?
    let userId: UUID
    let gearId: Int
    let isActive: Bool

    enum CodingKeys: String, CodingKey {
        case userGearId = "user_gear_id"
        case isActive = "is_active"
        case userId = "user_id"
        case gearId = "gear_id"
       
    }
    
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}
