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
    
    var user: UserItem
    var gear: Gear?
    
    enum CodingKeys: String, CodingKey {
        case id = "userGearID"
        case userId = "userID"
        case gearId = "gearID"
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

