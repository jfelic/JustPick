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

    // MARK: Create a session
    func createSession(sessionCode: String, title: String, selectedGenres: Set<String>) {
        
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
            "active": true
        ]
        
        // Save it to Firebase
        db.collection("sessions").document(sessionCode).setData(sessionData) { error in
            if error == nil {
                print("Session created successfully!")
            } else {
                print("Error creating session")
            }
        }
    }
    
    // MARK: Get Session Title
    func getSessionTitle() {
        
    }
}
