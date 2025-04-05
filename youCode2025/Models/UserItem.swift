//
//  UserItem.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

//
//  GearItem.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import Foundation

struct UserItem: Codable {
    
        let id: UUID
        let email: String
        let name: String
        let points: Int
        let createdAt: Date
        
        enum CodingKeys: String, CodingKey {
            case id
            case email
            case name
            case points
            case createdAt = "created_at"
        }
        
        
        func toJSONString() -> String? {
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(self) {
                return String(data: jsonData, encoding: .utf8)
            }
            return nil
        }
    }


