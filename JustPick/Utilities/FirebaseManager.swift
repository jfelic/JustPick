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

enum FirebaseError: Error {
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
            let result = try await Auth.auth().signInAnonymously() // returns a UserCredentials object
            
            // If we successfully get a user back
            // create our User model with their Firebase ID and chosen name
            self.currentUser = User(id: result.user.uid, name: name)
        } catch {
            print("Error signing in: \(error.localizedDescription)")
        }
    }
    
    // MARK: Add a user to session
    func addUserToSession(sessionCode: String, user: User) async throws {
        print("Adding user to session \(sessionCode)...")
        // Make sure we have a currentUser
        guard let currentUser = currentUser
            else {
                print("Cannot add user to session: No authenticated user")
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
        print("User \(user.id) added to session \(sessionCode) successfully")
    }
    
    // MARK: Remove user from session
    func removeUserFromSession(sessionCode: String, user: User) async throws {
        print("Removing user from session...")
        try await db.collection("sessions")
            .document(sessionCode)
            .collection("users")
            .document(user.id)
            .delete()
        print("User \(user.id) removed from session \(sessionCode)")
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
            "genres": Array(selectedGenres), // Make sure to cast selectedGenres from a Set to an Array
            "active": true,
        ]
        
        // Save it to Firebase
        do {
            try await db.collection("sessions")
                .document(sessionCode)
                .setData(sessionData)
            
            print("Session \(sessionCode) created successfully")
            
            try await addUserToSession(sessionCode: sessionCode, user: currentUser)
        } catch {
            print("Error creating session \(sessionCode): \(error.localizedDescription)")
        }
    }
    
    // MARK: Get Session Details
    func getSessionDetails(sessionCode: String) async throws -> SessionDetails {
        // Get the session document
        let documentSnapshot = try await db.collection("sessions")
            .document(sessionCode)
            .getDocument()
        
        // Make sure the session we're snapshotting has data
        guard let data = documentSnapshot.data() else {
            print("Input session code has no data")
            throw FirebaseError.invalidData
        }
        
        // Extract the data
        guard let title = data["title"] as? String,
              let genres = data["genres"] as? [String],
              let host = data["host"] as? String,
              let active = data["active"] as? Bool
        else {
            throw FirebaseError.decodingError
        }
        
        // Use the SessionDetails struct to store our fetched data
        return SessionDetails(title: title, selectedGenres: Set(genres), host: host, active: active)
        // Make sure to convert selectedGenres back to a Set
    }
    
    // MARK: Like Movie
    func likeMovie(movieID: Int, sessionCode: String) async throws {
        // Make sure we have a currentUser
        guard let currentUser = currentUser else {
            print("Cannot like movie: No authenticated user")
            return
        }
        
        print("Session code: \(sessionCode)")
        print("Current user ID: \(currentUser.id)")
        print("Attempting to like movie with ID: \(movieID)")
        
        // Create the data we want to send
        let voteData: [String: Any] = [
            "userID": currentUser.id,
            "\(movieID)": true,
        ]
        
        print("Creating vote document...")
        try await db.collection("sessions")
            .document(sessionCode)
            .collection("votes")
            .document(currentUser.id)
            .setData(voteData, merge: true)
        print("Vote successfully recorded")
    }
    
    // MARK: Dislike Movie
    func dislikeMovie(movieID: Int, sessionCode: String) async throws {
        // Make sure we have a currentUser
        guard let currentUser = currentUser else {
            print("Cannot dislike movie: No authenticated user")
            return
        }
        
        print("Attempting to dislike movie with ID: \(movieID)")
        print("Session code: \(sessionCode)")
        print("Current user ID: \(currentUser.id)")
        
        // Create the data we want to send
        let voteData: [String: Any] = [
            "userID": currentUser.id,
            "\(movieID)": false,
        ]
        
        print("Creating vote document...")
        try await db.collection("sessions")
            .document(sessionCode)
            .collection("votes")
            .document(currentUser.id)
            .setData(voteData, merge: true)
        print("Vote successfully recorded")
    }
    
    // MARK: Watch for matching votes
    func watchForMatchingVotes(sessionCode: String, completion: @escaping (Int) -> Void) {
        // Get snapshot of votes collection in given session
        let votesRef = db.collection("sessions")
            .document(sessionCode)
            .collection("votes")
        
        // Add listener to votes
        votesRef.addSnapshotListener { snapshot, error in
            // Make sure we have documents
            guard let documents = snapshot?.documents else { return }
            
            // Track likes for each movie
            var movieLikes: [String: Set<String>] = [:]
            
            // Go through each user's votes
            for document in documents {
                let userID = document.documentID
                let votes = document.data()
                
                // Check each movie vote
                for (movieID, vote) in votes {
                    // If user liked the movie
                    if let didLike = vote as? Bool, didLike {
                        // If this movie isn't in our tracking dict, add it with value = empty
                        if movieLikes[movieID] == nil {
                            movieLikes[movieID] = []
                        }
                        // Add this user's like
                        movieLikes[movieID]?.insert(userID)
                        
                        // If everyone in session liked this movie (and there's at least 2 prople in the session)
                        if movieLikes[movieID]?.count == documents.count && movieLikes[movieID]!.count > 1 {
                            if let movieIdInt = Int(movieID) {
                                completion(movieIdInt)
                            }
                        }
                    }
                }
            }
        }
    }
}
