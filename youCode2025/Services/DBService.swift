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
import PhotosUI



class DBService: ObservableObject {
    static let shared = DBService()
    
    private let client = SupabaseClient(supabaseURL: URL(string: "https://utjhoxwboarpagxbkmkv.supabase.co/")!, supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0amhveHdib2FycGFneGJrbWt2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4MzAyNDEsImV4cCI6MjA1OTQwNjI0MX0.LaXrVsorQPxEj3Leg8FVaz5mLOu6dN3Z8jS4iuOU5VM")
    
    @Published var user: Profile? = nil
    
    private let session: URLSession

    func getFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX" // Supports timezones like +00:00
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter
    }
    
    
    
    
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
    
//    func signUp(email: String, password: String, firstName: String, lastName: String) async throws {
//        let result = try await client.auth.signUp(email: email, password: password)
//
//        let user = result.user
//
//        let profile = Profile(id: user.id, email: email, firstName: firstName, lastName: lastName)
//
//        let _ = try await client
//            .from("Profiles")
//            .insert([profile])
//            .execute()
//        
//        await MainActor.run {
//            self.user = profile
//        }
//    }
    
    func signUp(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        profileUIImage: UIImage?
    ) async throws {
        let result = try await client.auth.signUp(email: email, password: password)
        let user = result.user

        var imageURL: String? = nil
        if let imageData = profileUIImage?.jpegData(compressionQuality: 0.8) {
            imageURL = try await uploadProfileImage(userId: user.id, imageData: imageData)
        }

        let profile = Profile(
            id: user.id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            points: 0,
            profilePhotoURL: imageURL
        )

        _ = try await client
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
        decoder.dateDecodingStrategy = .formatted(getFormatter())

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
        let data = try await client
            .from("Profiles")
            .select()
            .execute()
            .data

        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "signIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert data to string"])
        }

        print("Raw JSON response - : \(jsonString)")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getFormatter())

        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let profiles = try decoder.decode([Profile].self, from: jsonData)

                return profiles
            } catch {
                print("Decoding error: \(error)")
            }
        } else {
            print("Could not convert JSON string back to Data")
        }
        
        return []
    }
    
    // Gets one user by their ID
    func getUser(id: UUID) async throws -> Profile {
        do {
            let response = try await client
                .from("Profiles")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
            
            guard let jsonString = String(data: response.data, encoding: .utf8) else {
                throw NSError(domain: "getUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert data to string"])
            }

            print("Raw JSON response - getUser: \(jsonString)")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(getFormatter())

            guard let jsonData = jsonString.data(using: .utf8) else {
                throw NSError(domain: "getUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to re-encode JSON string"])
            }

            let res = try decoder.decode(Profile.self, from: jsonData)
            print("Decoded Profile:", res)

            await MainActor.run {
                self.user = res
            }

            return res
        } catch {
            print("❌ Error in getUser:", error)
            throw error
        }
    }
    
    // Creates a new user
//    func createUser(email: String, name: String, password: String) async throws -> Profile {
//        return try await sendRequest(
//            endpoint: "Profile",
//            method: "POST",
//            body: ["email": email, "name": name, "password_hash": password, "points": 0] // TODO
//        ).first!
//    }
//    
    // Updates a user's information
//    func updateUser(id: UUID, updates: [String: Any]) async throws -> Profile {
//        return try await sendRequest(
//            endpoint: "Profile",
//            method: "PATCH",
//            queryItems: [URLQueryItem(name: "id", value: "eq.\(id.uuidString)")],
//            body: updates
//        ).first!
//    }
    
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

        print("Raw JSON response - getAllGear: \(jsonString)")

        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .formatted(getFormatter())

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
        let data = try await client
            .from("Gear")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .data
        
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "getGear", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert data to string"])
        }

        print("Raw JSON response - getGear: \(jsonString)")

        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .formatted(getFormatter())

        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "getGear", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to re-encode JSON string"])
        }
        let res = try decoder.decode(GearItem.self, from: jsonData)
        print(res)
        return res
        
        
//        if let jsonData = jsonString.data(using: .utf8) {
//            do {
//                let gear = try decoder.decode(GearItem.self, from: jsonData)
//
//                return gear
//            } catch {
//                print("Decoding error: \(error)")
//            }
//        } else {
//            print("Could not convert JSON string back to Data")
//        }
//        
//        return nil
    }
    
    // Creates a new gear item
    func createGear(
        name: String,
        type: GearItem.GearType,
        description: String,
        currentCondition: GearItem.GearCondition,
        latitude: Double,
        longitude: Double,
        isAvailable: Bool,
        gearUIImage: UIImage?
    ) async throws -> GearItem {

        var newGear = GearItem(
            id: nil,
//            createdAt: nil,
            name: name,
            type: type,
            description: description,
            currentCondition: currentCondition,
            latitude: latitude,
            longitude: longitude,
            isAvailable: isAvailable,
            gearPhotoURL: nil
        )

        let insertedData = try await client
            .from("Gear")
            .insert([newGear])
            .select()
            .single()
            .execute()
            .data

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getFormatter())

        guard let insertedJsonString = String(data: insertedData, encoding: .utf8),
              let insertedJsonData = insertedJsonString.data(using: .utf8) else {
            throw NSError(domain: "createGear", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse inserted gear"])
        }

        var insertedGear = try decoder.decode(GearItem.self, from: insertedJsonData)

        if let gearUIImage = gearUIImage,
           let imageData = gearUIImage.jpegData(compressionQuality: 0.8),
           let gearId = insertedGear.id {
            let imageURL = try await uploadGearImage(gearId: gearId, imageData: imageData)

            struct UpdatePayload: Codable {
                let gearPhotoURL: String
                
                enum CodingKeys: String, CodingKey {
                    case gearPhotoURL = "gear_photo_url"
                }
            }
            
            let updatePayload = UpdatePayload(gearPhotoURL: imageURL)

            let updatedData = try await client
                .from("Gear")
                .update(updatePayload)
                .eq("id", value: gearId)
                .select()
                .single()
                .execute()
                .data

            guard let updatedJsonString = String(data: updatedData, encoding: .utf8),
                  let updatedJsonData = updatedJsonString.data(using: .utf8) else {
                throw NSError(domain: "createGear", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse updated gear"])
            }

            insertedGear = try decoder.decode(GearItem.self, from: updatedJsonData)
        }

        return insertedGear
    }

    
    // Updates a gear item
    func updateGear(
        id: Int,
        currentCondition: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        isAvailable: Bool? = nil
    ) async throws -> GearItem {
        
        let updatePayload = GearUpdate(
            currentCondition: currentCondition,
            latitude: latitude,
            longitude: longitude,
            isAvailable: isAvailable
        )

        let data = try await client
            .from("Gear")
            .update(updatePayload)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .data

        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "updateGear", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"])
        }

        print("Raw JSON response - updateGear: \(jsonString)")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getFormatter())

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "updateGear", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to re-encode JSON string"])
        }
        let res = try decoder.decode(GearItem.self, from: jsonData)
        print(res)
        return res
    }
    
    
    // Gets all gear for a specific user
//    func getUserGear(userId: UUID) async throws -> [UserGearItem] {
//        let userGears: [UserGearItem] = try await sendRequest(
//            endpoint: "UserGears",
//            method: "GET",
//            queryItems: [URLQueryItem(name: "userID", value: "eq.\(userId.uuidString)")]
//        )
//        
//        // Load the gear details for each user gear
//        var result = [UserGearItem]()
//        for var userGear in userGears {
//            userGear.gear = try await getGear(id: userGear.gearId)
//            result.append(userGear)
//        }
//        
//        return result
//    }
    
    // Connects a gear item to a user
    func associateGearWithUser(userId: UUID, gearId: Int) async throws -> UserGearLink {
        if !(try await getGear(id: gearId).isAvailable) {
            throw NSError(domain: "AppError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch gear."])
        }
        
        let response = try await client
            .from("UserGears")
              .select("*", head: true, count: .exact)
              .eq("user_id", value: userId.uuidString)
              .eq("gear_id", value: gearId)
              .execute()

        // Extract the count result
        guard let count = response.count else {
            throw NSError(domain: "SupabaseError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch count."])
        }

            // If the count is greater than 0, the link exists
        if count > 0 {
            print("Link already exists")
            return try await updateGearUser(userId: userId, gearId: gearId, isActive: true)
        }
        
        let newLink = UserGearLink(userGearId: nil, userId: userId, gearId: gearId, isActive: true)

        let data = try await client
            .from("UserGears")
            .insert([newLink])
            .select()
            .single()
            .execute()
            .data

        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "associateGearWithUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"])
        }

        print("Raw JSON response - associateGearWithUser: \(jsonString)")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getFormatter())

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "associateGearWithUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to re-encode JSON string"])
        }
        
        do {
            let userGearItem = try decoder.decode(UserGearLink.self, from: jsonData)
            return userGearItem
        } catch {
            print("Decoding error: \(error)")
        }
        

        return try decoder.decode(UserGearLink.self, from: jsonData)
    }

    
    func updateGearUser(userId: UUID, gearId: Int, isActive: Bool) async throws -> UserGearLink {

        let update = UserGearItemUpdate(isActive: isActive)
        
        let data = try await client
            .from("UserGears")
            .update(update)
            .eq("user_id", value: userId.uuidString)
            .eq("gear_id", value: gearId)
            .select()
            .single()
            .execute()
            .data

        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "disassociateGearFromUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"])

        }

        print("Raw JSON response - disassociateGearFromUser: \(jsonString)")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getFormatter())

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "disassociateGearFromUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to re-encode JSON string"])
        }
        
        do {
            let userGearItem = try decoder.decode(UserGearLink.self, from: jsonData)
            return userGearItem
        } catch {
            print("Decoding error: \(error)")
        }
        

        return try decoder.decode(UserGearLink.self, from: jsonData)
    }
    
    func getGearItemsForUser(userId: UUID) async throws -> [GearItem] {
        let userGearsData = try await client
            .from("UserGears")
            .select("gear_id")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .data
        guard let gearIdsJsonString = String(data: userGearsData, encoding: .utf8),
              let gearIdsData = gearIdsJsonString.data(using: .utf8) else {
            throw NSError(domain: "getGearItemsForUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert gearIds data"])
        }

        
        
        struct GearIdWrapper: Codable {
            let gear_id: Int
        }

        let gearIdWrappers = try JSONDecoder().decode([GearIdWrapper].self, from: gearIdsData)
        let gearIds = gearIdWrappers.map { $0.gear_id }

        if gearIds.isEmpty {
            return []
        }
        
        let gearData = try await client
            .from("Gear")
            .select()
            .in("id", values: gearIds)
            .execute()
            .data

        guard let gearJsonString = String(data: gearData, encoding: .utf8),
              let gearJsonData = gearJsonString.data(using: .utf8) else {
            throw NSError(domain: "getGearItemsForUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert gear data"])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getFormatter())
        let gearItems = try decoder.decode([GearItem].self, from: gearJsonData)

        return gearItems
    }
    
    func getUserForGearItem(gearId: Int) async throws -> Profile? {
        let userGearData = try await client
            .from("UserGears")
            .select("user_id")
            .eq("gear_id", value: gearId)
            .eq("is_active", value: true)
            .single()
            .execute()
            .data

        guard let userJsonString = String(data: userGearData, encoding: .utf8),
              let userJsonData = userJsonString.data(using: .utf8) else {
            throw NSError(domain: "getUserForGearItem", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert userId data"])
        }

        struct UserIdWrapper: Codable {
            let user_id: UUID
        }

        let userIdWrapper = try JSONDecoder().decode(UserIdWrapper.self, from: userJsonData)

        let userData = try await client
            .from("Profiles")
            .select()
            .eq("id", value: userIdWrapper.user_id.uuidString)
            .single()
            .execute()
            .data

        guard let userProfileJson = String(data: userData, encoding: .utf8),
              let userProfileData = userProfileJson.data(using: .utf8) else {
            throw NSError(domain: "getUserForGearItem", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert profile data"])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getFormatter())
        let profile = try decoder.decode(Profile.self, from: userProfileData)
        
        
        return profile
    }

    
    func getActiveGearItemsForUser(userId: UUID) async throws -> [GearItem] {
        let userGearsData = try await client
            .from("UserGears")
            .select("gear_id")
            .eq("user_id", value: userId.uuidString)
            .eq("is_active", value: true)
            .execute()
            .data
        guard let gearIdsJsonString = String(data: userGearsData, encoding: .utf8),
              let gearIdsData = gearIdsJsonString.data(using: .utf8) else {
            throw NSError(domain: "getGearItemsForUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert gearIds data"])
        }

        struct GearIdWrapper: Codable {
            let gear_id: Int
        }

        let gearIdWrappers = try JSONDecoder().decode([GearIdWrapper].self, from: gearIdsData)
        let gearIds = gearIdWrappers.map { $0.gear_id }

        if gearIds.isEmpty {
            return []
        }
        
        let gearData = try await client
            .from("Gear")
            .select()
            .in("id", values: gearIds)
            .execute()
            .data

        guard let gearJsonString = String(data: gearData, encoding: .utf8),
              let gearJsonData = gearJsonString.data(using: .utf8) else {
            throw NSError(domain: "getGearItemsForUser", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert gear data"])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getFormatter())
        let gearItems = try decoder.decode([GearItem].self, from: gearJsonData)

        return gearItems
    }
    
    func uploadProfileImage(userId: UUID, imageData: Data, fileExtension: String = "jpg") async throws -> String {
        let filePath = "profiles/\(userId.uuidString).\(fileExtension)"
        let bucket = client.storage.from("profile-photos")

        _ = try await bucket.upload(
            filePath,
            data: imageData,
            options: FileOptions(contentType: "image/\(fileExtension)", upsert: true)
        )

    return try bucket.getPublicURL(path: filePath, download: false).absoluteString
    }
    
    func uploadGearImage(gearId: Int, imageData: Data, fileExtension: String = "jpg") async throws -> String {
        let filePath = "gear/\(gearId).\(fileExtension)"
        let bucket = client.storage.from("gear-photos")

        _ = try await bucket.upload(
            filePath,
            data: imageData,
            options: FileOptions(contentType: "image/\(fileExtension)", upsert: true)
        )

        return try bucket.getPublicURL(path: filePath, download: false).absoluteString
    }

//    func updateProfileImageURL(for userId: UUID, imageURL: String) async throws {
//        _ = try await client
//            .from("Profiles")
//            .update(["profile_image_url": imageURL])
//            .eq("id", value: userId.uuidString)
//            .execute()
//    }
    

    func updateProfile(
        id: UUID,
        email: String? = nil,
        points: Int? = nil,
        distanceHiked: Int? = nil,
        profilePhotoURL: String? = nil
    ) async throws -> Profile {
        
        let updatePayload = ProfileUpdate(
            email: email,
            points: points,
            distanceHiked: distanceHiked,
            profilePhotoURL: profilePhotoURL
        )

        let data = try await client
            .from("Profiles")
            .update(updatePayload)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .data

        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "updateProfile", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to string"])
        }

        print("Raw JSON response - updateGear: \(jsonString)")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(getFormatter())

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "updateProfile", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to re-encode JSON string"])
        }
        let res = try decoder.decode(Profile.self, from: jsonData)
        print(res)
        return res
    }
}
