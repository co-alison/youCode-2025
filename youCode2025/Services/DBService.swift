//
//  DBService.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//  Code from: https://supabase.com/docs/guides/getting-started/tutorials/with-swift
//

import Supabase
import Combine
import Foundation

class DBService: ObservableObject {
    static let shared = DBService()
    
    private let client = SupabaseClient(supabaseURL: URL(string: "https://utjhoxwboarpagxbkmkv.supabase.co/")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0amhveHdib2FycGFneGJrbWt2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4MzAyNDEsImV4cCI6MjA1OTQwNjI0MX0.LaXrVsorQPxEj3Leg8FVaz5mLOu6dN3Z8jS4iuOU5VM")
    
    @Published var user: Profile? = nil
    
    private let session: URLSession
    
    init() {
        
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "apikey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0amhveHdib2FycGFneGJrbWt2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4MzAyNDEsImV4cCI6MjA1OTQwNjI0MX0.LaXrVsorQPxEj3Leg8FVaz5mLOu6dN3Z8jS4iuOU5VM",
            "Content-Type": "application/json"
        ]
        self.session = URLSession(configuration: config)
        checkSession()
    }
    
    func checkSession() {
        Task {
            if let session = try? await client.auth.session {
                await MainActor.run {
                    
                }
            }
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
        let result = try await client.auth.signUp(email: email, password: password)

        let user = result.user

        let profile = Profile(id: user.id, email: email, firstName: firstName, lastName: lastName)

        let insertResponse = try await client
            .from("Profiles")
            .insert([profile])
            .execute()
        
        await MainActor.run {
            self.user = profile
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        let user = session.user

        print("User ID:", user.id.uuidString)

        let data = try await client
            .from("Profiles")
            .select()
            .eq("id", value: user.id.uuidString)
            .single()
            .execute()
            .data

        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "signIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert data to string"])
        }

        print("Raw JSON response: \(jsonString)")

        let decoder = JSONDecoder()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX" // Supports timezones like +00:00
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(formatter)

        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let profile = try decoder.decode(Profile.self, from: jsonData)

                await MainActor.run {
                    self.user = profile
                }
            } catch {
                print("Decoding error: \(error)")
            }
        } else {
            print("Could not convert JSON string back to Data")
        }
    }


    
    func signOut() async throws {
        try await client.auth.signOut()
        await MainActor.run {
            self.user = nil
        }
    }
    
    // Gets all users
    func getUsers() async throws -> [Profile] {
        return try await sendRequest(endpoint: "Profile", method: "GET")
    }
    
    // Gets one user by their ID
    func getUser(id: UUID) async throws -> Profile {
        return try await sendRequest(endpoint: "Profile", method: "GET", queryItems: [
            URLQueryItem(name: "id", value: "eq.\(id.uuidString)")
        ]).first!
    }
    
    // Creates a new user
    func createUser(email: String, name: String, password: String) async throws -> Profile {
        return try await sendRequest(
            endpoint: "Profile",
            method: "POST",
            body: ["email": email, "name": name, "password_hash": password, "points": 0] // TODO
        ).first!
    }
    
    // Updates a user's information
    func updateUser(id: UUID, updates: [String: Any]) async throws -> Profile {
        return try await sendRequest(
            endpoint: "Profile",
            method: "PATCH",
            queryItems: [URLQueryItem(name: "id", value: "eq.\(id.uuidString)")],
            body: updates
        ).first!
    }
    
    // Gets all gear items
    func getAllGear() async throws -> [GearItem] {
        let data = try await client
            .from("Gear")
            .select()
            .execute()
            .data
        
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "signIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert data to string"])
        }

        print("Raw JSON response: \(jsonString)")

        let decoder = JSONDecoder()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX" // Supports timezones like +00:00
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(formatter)

        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let gears = try decoder.decode([GearItem].self, from: jsonData)

                return gears
            } catch {
                print("Decoding error: \(error)")
            }
        } else {
            print("Could not convert JSON string back to Data")
        }
        
        return []
    }
    
    // Gets one gear item by its ID
    func getGear(id: Int) async throws -> GearItem {
        return try await sendRequest(endpoint: "Gear", method: "GET", queryItems: [
            URLQueryItem(name: "id", value: "eq.\(id)")
        ]).first!
    }
    
    // Creates a new gear item
    func createGear(name: String, type: String, description: String,
                    currentCondition: String, latitude: Double, longitude: Double, isAvailable: Bool) async throws -> GearItem {
        return try await sendRequest(
            endpoint: "Gear",
            method: "POST",
            body: [
                "name": name,
                "type": type,
                "description": description,
                "current_condition": currentCondition,
                "latitude": latitude,
                "longitude": longitude,
                "is_available": isAvailable
            ]
        ).first!
    }
    
    // Updates a gear item
    func updateGear(id: Int, updates: [String: Any]) async throws -> GearItem {
        return try await sendRequest(
            endpoint: "Gear",
            method: "PATCH",
            queryItems: [URLQueryItem(name: "id", value: "eq.\(id)")],
            body: updates
        ).first!
    }
    
    
    // Gets all gear for a specific user
    func getUserGear(userId: UUID) async throws -> [UserGearItem] {
        let userGears: [UserGearItem] = try await sendRequest(
            endpoint: "UserGears",
            method: "GET",
            queryItems: [URLQueryItem(name: "user_id", value: "eq.\(userId.uuidString)")]
        )
        
        // Load the gear details for each user gear
        var result = [UserGearItem]()
        for var userGear in userGears {
            userGear.gear = try await getGear(id: userGear.gearId)
            result.append(userGear)
        }
        
        return result
    }
    
    // Connects a gear item to a user
    func associateGearWithUser(userId: UUID, gearId: Int) async throws -> UserGearItem {
        return try await sendRequest(
            endpoint: "UserGears",
            method: "POST",
            body: ["user_id": userId.uuidString, "gear_id": gearId, "is_active": true]
        ).first!
    }
    
    func disassociateGearFromUser(userId: UUID, gearId: Int) async throws -> UserGearItem {
        return try await sendRequest(
            endpoint: "UserGears",
            method: "UPDATE",
            body: ["user_id": userId.uuidString, "gear_id": gearId, "is_active": false]
        ).first!
    }
    
    private func sendRequest<T: Decodable>(
        endpoint: String,
        method: String,
        queryItems: [URLQueryItem] = [],
        body: Any? = nil,
        as type: T.Type = T.self  // Add this parameter
    ) async throws -> [T] {
        var components = URLComponents(string: "\("https://utjhoxwboarpagxbkmkv.supabase.co/")/\(endpoint)")!
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
