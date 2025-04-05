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
    
    @Published var user: User? = nil
    
    init() {
        checkSession()
    }
    
    func checkSession() {
        Task {
            if let session = try? await client.auth.session {
                await MainActor.run {
                    self.user = session.user
                }
            }
        }
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await client.auth.signUp(email: email, password: password)
        
        await MainActor.run {
            self.user = result.user
        }
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await client.auth.signIn(email: email, password: password)
        
        await MainActor.run {
            self.user = result.user
        }
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        await MainActor.run {
            self.user = nil
        }
    }
}
