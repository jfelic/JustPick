//
//  HostSessionView.swift
//  JustPick
//
//  Created by Julian on 11/27/24.
//

import SwiftUI

struct HostSessionView: View {
    
    @State private var title = ""
    @State private var sessionCode = ""
    @State private var name = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager // interact with Firebase
    @State private var navigateToSessionView = false // State to trigger navigation
    
    let genres: [String: Int] = ["Action": 28, "Adventure": 12, "Comedy": 35, "Drama": 18, "Fantasy": 14, "Horror": 27, "Mystery": 9648, "Romance": 10749, "Science Fiction": 878, "Thriller": 53]
    @State private var selectedGenres: Set<String> = []
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Session Code: ")
                            .font(.custom("RobotoSlab-Bold", size: 18))
                            .foregroundStyle(Color.theaterRed)
                        Text("<\(sessionCode)>")
                            .font(.custom("RobotoSlab-Regular", size: 18))
                            .foregroundStyle(Color.popcornYellow)
                    }
                    
                    Spacer()
                    
                    CustomTextField(label: "Session Title: ", text: $title)
                    
                    CustomTextField(label: "Your name: ", text: $name)
                    
                    Spacer()
                    
                    Text("Choose Genres: ")
                        .font(.custom("RobotoSlab-Bold", size: 18))
                        .foregroundStyle(Color.theaterRed)
                    
                    ScrollView {
                        VStack {
                            ForEach(genres.keys.sorted(), id: \.self) { genre in
                                GenreCheckbox(
                                    title: genre,
                                    isSelected: selectedGenres.contains(genre),
                                    action: {
                                        // Toggle selection
                                        if selectedGenres.contains(genre) {
                                            selectedGenres.remove(genre)
                                        } else {
                                            selectedGenres.insert(genre)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    
                    Spacer()
            
                    Button(action: {
                        print("HostSessionView: Host Pressed")
                        
                        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
                              !name.trimmingCharacters(in: .whitespaces).isEmpty else {
                            print("Title or name is empty")
                            return
                        }
                        
                        Task {
                            // Sign in anonymous user with their chosen name
                            await firebaseManager.signInAnonymously(name: name)
                            
                            // Create session with current user as host
                            await firebaseManager.createSession(sessionCode: sessionCode, title: title, selectedGenres: selectedGenres)
                            
                            // Lastly, navigate user to session screen
                            navigateToSessionView = true
                        }
                    }) {
                        Text("Host Session")
                            .font(.custom("RobotoSlab-Bold", size: 30))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.theaterRed)
                            .foregroundColor(Color.popcornYellow)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(
                        destination: SessionView(sessionCode: sessionCode, sessionTitle: title, selectedGenres: selectedGenres),
                        isActive: $navigateToSessionView
                    ) {
                        EmptyView()
                    }
                }
                .padding()

            }
            .navigationBarBackButtonHidden(true)
            .background(Color.backgroundNavy)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.popcornYellow)
                    }
                    .padding(.leading)
                }
                ToolbarItem(placement: .principal) {
                    Text("Host a Session")
                        .font(.custom("RobotoSlab-Bold", size: 30))
                        .foregroundStyle(Color.theaterRed)
//                        .padding(.top)
                }
            }
            .onTapGesture { // Dismiss keyboard when user taps outside of it
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
            .onAppear { // Generate session code
                sessionCode = String(Int.random(in: 1000...99999))
            }
        }
    }
}

struct GenreCheckbox: View {
    let title: String // Genre name
    let isSelected: Bool // Whether this genre is selected
    let action: () -> Void // Action to perform when tapped
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(.popcornYellow)
                Text(title)
                    .font(.custom("RobotoSlab-Regular", size: 18))
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .padding()
        }
    }
}

//#Preview {
//    HostSessionView()
//}
