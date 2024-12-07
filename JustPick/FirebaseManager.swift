//
//  FirebaseManager.swift
//  JustPick
//
//  Created by Julian on 12/6/24.
//

import FirebaseAuth
import FirebaseFirestore

struct User {
    let id: String
    let name: String
}

struct SessionDetails {
    let title: String
    let selectedGenres: Set<String>
    let host: String
    let active: Bool
}

enum NetworkError: Error {
    case invalidData
    case decodingError
    case serverError
    case noSession
}

class FirebaseManager: ObservableObject {
    @Published var currentUser: User?
    let db = Firestore.firestore()
    
    // MARK: Sign in anonymously and create user with name
    func signInAnonymously(name: String) async {
        do {
            // Try to sign in and wait for result
            let result = try await Auth.auth().signInAnonymously()
            
            // If we successfully get a user back
            // create our User model with their Firebase ID and chosen name
            self.currentUser = User(id: result.user.uid, name: name)
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }
    
    // MARK: Add a user to session
    func addUserToSession(sessionCode: String, user: User) async throws {
        // Make sure we have a currentUser
        guard let currentUser = currentUser
            else {
                print("Hello")
                return
            }
        
        // Create the user data
        let userData: [String: Any] = [
            "id": user.id,
            "name": user.name,
            "joinedAt": Timestamp(),
        ]
        
        // Using the async version of setData
        try await db.collection("sessions")
            .document(sessionCode)
            .collection("users")
            .document(user.id)
            .setData(userData)
    }

    // MARK: Create a session
    func createSession(sessionCode: String, title: String, selectedGenres: Set<String>) async {
        
        // Make sure we have a currentUser
        guard let currentUser = currentUser
            else {
                print("Cannot create session: No authenticated user")
                return
            }
        
        // Create session document in sessions collection
        let sessionData: [String: Any] = [
            "host": currentUser.id,
            "title": title,
            "createdAt": Timestamp(),
            "genres": Array(selectedGenres),
            "active": true,
        ]
        
        // Save it to Firebase
        do {
            try await db.collection("sessions")
                .document(sessionCode)
                .setData(sessionData)
            
            print("Session created successfully")
            
            try await addUserToSession(sessionCode: sessionCode, user: currentUser)
        } catch {
            print("Error creating session: \(error.localizedDescription)")
        }
    }
    
    func getSessionDetails(sessionCode: String) async throws -> SessionDetails {
        // Get the session document
        let documentSnapshot = try await db.collection("sessions")
            .document(sessionCode)
            .getDocument()
        
        guard let data = documentSnapshot.data() else {
            throw NetworkError.invalidData
        }
        
        // Extract the data
        guard let title = data["title"] as? String,
              let genres = data["genres"] as? [String],
              let host = data["host"] as? String,
              let active = data["active"] as? Bool else {
            throw NetworkError.decodingError
        }
        
        return SessionDetails(title: title, selectedGenres: Set(genres), host: host, active: active)
    }
}