//
//  SupabaseClient.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import Foundation

class SupabaseClient {
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession
    
    init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "apikey": apiKey,
            "Content-Type": "application/json"
        ]
        self.session = URLSession(configuration: config)
    }
    
    // Gets all users
    func getUsers() async throws -> [User] {
        return try await sendRequest(endpoint: "User", method: "GET")
    }
    
    // Gets one user by their ID
    func getUser(id: UUID) async throws -> User {
        return try await sendRequest(endpoint: "User", method: "GET", queryItems: [
            URLQueryItem(name: "id", value: "eq.\(id.uuidString)")
        ]).first!
    }
    
    // Creates a new user
    func createUser(email: String, name: String, password: String) async throws -> User {
        return try await sendRequest(
            endpoint: "User",
            method: "POST",
            body: ["email": email, "name": name, "password_hash": password, "points": 0]
        ).first!
    }
    
    // Updates a user's information
    func updateUser(id: UUID, updates: [String: Any]) async throws -> User {
        return try await sendRequest(
            endpoint: "User",
            method: "PATCH",
            queryItems: [URLQueryItem(name: "id", value: "eq.\(id.uuidString)")],
            body: updates
        ).first!
    }
    
    // Gets all gear items
    func getAllGear() async throws -> [Gear] {
        return try await sendRequest(endpoint: "Gear", method: "GET")
    }
    
    // Gets one gear item by its ID
    func getGear(id: Int) async throws -> Gear {
        return try await sendRequest(endpoint: "Gear", method: "GET", queryItems: [
            URLQueryItem(name: "id", value: "eq.\(id)")
        ]).first!
    }
    
    // Creates a new gear item
    func createGear(name: String, type: String, description: String,
                   currentCondition: String, latitude: Double, longitude: Double) async throws -> Gear {
        return try await sendRequest(
            endpoint: "Gear",
            method: "POST",
            body: [
                "name": name,
                "type": type,
                "description": description,
                "current_condition": currentCondition,
                "latitude": latitude,
                "longitude": longitude
            ]
        ).first!
    }
    
    // Updates a gear item
    func updateGear(id: Int, updates: [String: Any]) async throws -> Gear {
        return try await sendRequest(
            endpoint: "Gear",
            method: "PATCH",
            queryItems: [URLQueryItem(name: "id", value: "eq.\(id)")],
            body: updates
        ).first!
    }
    
    
    // Gets all gear for a specific user
    func getUserGear(userId: UUID) async throws -> [UserGear] {
        let userGears: [UserGear] = try await sendRequest(
            endpoint: "UserGears",
            method: "GET",
            queryItems: [URLQueryItem(name: "userID", value: "eq.\(userId.uuidString)")]
        )
        
        // Load the gear details for each user gear
        var result = [UserGear]()
        for var userGear in userGears {
            userGear.gear = try await getGear(id: userGear.gearId)
            result.append(userGear)
        }
        
        return result
    }
    
    // Connects a gear item to a user
    func associateGearWithUser(userId: UUID, gearId: Int) async throws -> UserGear {
        return try await sendRequest(
            endpoint: "UserGears",
            method: "POST",
            body: ["userID": userId.uuidString, "gearID": gearId]
        ).first!
    }
    
    
    
    private func sendRequest<T: Decodable>(
        endpoint: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        body: Any? = nil,
        as type: T.Type = T.self  // Add this parameter
    ) async throws -> [T] {
        var components = URLComponents(string: "\(baseURL)/\(endpoint)")!
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        if method == "POST" || method == "PATCH" {
            request.addValue("return=representation", forHTTPHeaderField: "Prefer")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw NSError(
                domain: "SupabaseClient",
                code: httpResponse.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode)",
                    "responseData": String(data: data, encoding: .utf8) ?? "No data"
                ]
            )
        }
        
        if method == "DELETE" && data.isEmpty {
            return [] as! [T]
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([T].self, from: data)
    }
    }
    
