//
//  UserGearItem.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import Foundation

struct UserGearItem: Codable {
    
    let id: Int
    let userId: UUID
    let gearId: Int
    let isActive: Bool
    var user: Profile
    var gear: GearItem?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_gear_id"
        case userId = "user_id"
        case gearId = "gear_id"
        case isActive = "is_active"
        case user, gear
        }
        
        
        func toJSONString() -> String? {
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(self) {
                return String(data: jsonData, encoding: .utf8)
            }
            return nil
        }
    }

