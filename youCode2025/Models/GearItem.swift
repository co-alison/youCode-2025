//
//  GearItem.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import Foundation

struct GearItem: Codable {
    let id: String
    let gearType: GearType
    let latitude: Double
    let longitude: Double
    let name: String
    let description: String
    
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            return String(data: jsonData, encoding: .utf8)
        }
        return nil
    }
}

enum GearType: Int, Codable {
    case boots
    case jacket
}
