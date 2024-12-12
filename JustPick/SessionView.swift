//
//  SessionView.swift
//  JustPick
//
//  Created by Julian on 12/6/24.
//

import SwiftUI

struct SessionView: View {
    
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @Environment(\.dismiss) var dismiss
    @Environment(NetworkManager.self) private var networkManager
    
    // Shared session info
    let sessionCode: String // Passed in from HostSessionView
    let sessionTitle: String // Passed in from HostSessionView
    @State var selectedGenres: Set<String> = ["Action"] // Passed in from HostSessionView
    @State var participants: [User] = []
    @State var currentMovieIndex = 0
    @State var showToolBar = true
    @State private var showMatchOverlay = false
    @State private var matchedMovie: Movie? = nil
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    AsyncImage(url: networkManager.movies[currentMovieIndex].fullPosterPath) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 300, height: 375)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 275, height: 375)
                                .clipped()
                                .cornerRadius(8)
                                .shadow(radius: 1)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 300, height: 375)
                                .cornerRadius(30)
                        @unknown default:
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 300, height: 375)
                                .cornerRadius(10)
                        }
                        
                    }
                    
                    
                    Text(networkManager.movies[currentMovieIndex].title)
                        .font(.custom("RobotoSlab-Bold", size: 25))
                        .foregroundStyle(Color.white)
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        // TODO: Reset scroll position when like/dislike tapped
                        Task {
                            try await firebaseManager.likeMovie(movieID: networkManager.movies[currentMovieIndex].id, sessionCode: sessionCode)
                            currentMovieIndex += 1
                        }
                    }) {
                        // Like Button
                        if #available(iOS 18.0, *) {
                            Image(systemName: "hand.thumbsup")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color.buttonGreen)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.borderGreen, lineWidth: 2)
                                )
                                .symbolEffect(.bounce, options: .repeat(4))
                        } else {
                            // Remove symbolEffect if not iOS 18+
                            Image(systemName: "hand.thumbsup")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color.buttonGreen)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.borderGreen, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.trailing, 10)
                    
                    // Dislike button
                    Button(action: {
                        // TODO: Reset scroll position when like/dislike tapped
                        Task {
                            try await firebaseManager.dislikeMovie(movieID: networkManager.movies[currentMovieIndex].id, sessionCode: sessionCode)
                            currentMovieIndex += 1
                        }
                    }) {
                        if #available(iOS 18.0, *) {
                            Image(systemName: "hand.thumbsdown")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color.theaterRed)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.borderRed, lineWidth: 2)
                                )
                                .symbolEffect(.bounce, options: .repeat(4))
                        } else {
                            // Remove symbolEffect if not iOS 18+
                            Image(systemName: "hand.thumbsdown")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color.theaterRed)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.borderRed, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.leading, 10)
                }
                
                Spacer()
                
                ScrollView {
                    Text(networkManager.movies[currentMovieIndex].overview)
                        .frame(maxWidth: .infinity)
                        .font(.custom("RobotoSlab-Regular", size: 18))
                        .foregroundStyle(Color.white)
                        .padding()
                }
                
            } // Main VStack end
            .padding()
            .background(Color.backgroundNavy)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if showToolBar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action : {
                            dismiss()
                            Task {
                                if firebaseManager.currentUser != nil {
                                    try await firebaseManager.removeUserFromSession(sessionCode: sessionCode, user: firebaseManager.currentUser!)
                                } else {
                                    print("Unable to remove user from session, currentUser == nil")
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color.popcornYellow)
                        }
                        .padding(.leading)
                    }
                    ToolbarItem(placement: .principal) {
                        Text(sessionTitle)
                            .font(.custom("RobotoSlab-Bold", size: 30))
                            .foregroundStyle(Color.theaterRed)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(sessionCode)
                            .font(.custom("RobotoSlab-Bold", size: 20))
                            .foregroundStyle(Color.popcornYellow)
                            .padding()
                    }
                }

            }
            .onAppear {
                Task {
                    await networkManager.loadMovies()
                }
                firebaseManager.watchForMatchingVotes(sessionCode: sessionCode) {matchedMovieId in
                    print("Everyone liked movie: \(matchedMovieId)")
                    
                    // Get movie with ID
                    Task {
                        matchedMovie = try await networkManager.fetchMovieByID(movieID: matchedMovieId)
                    }
                    
                    // Disable toolbar
                    showToolBar = false
                    
                    // Display overlay
                    showMatchOverlay = true
                }
            }
            .overlay {
                if showMatchOverlay {
                    ZStack {
                        Color.black.opacity(0.9)
                            .ignoresSafeArea()
                        
                        VStack {
                            Text("Movie Matched! 🎉")
                                .font(.custom("RobotoSlab-Bold", size: 30))
                                .foregroundStyle(Color.white)
                                .padding()
                            
                            Spacer()
                            
                            if let movie = matchedMovie {
                                AsyncImage(url: movie.fullPosterPath) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 300, height: 375)
//                                            .clipped()
                                            .cornerRadius(8)
                                            .shadow(radius: 1)
                                    case .failure:
                                        Image(systemName: "film")
                                        .frame(width: 300, height: 375)
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 300, height: 375)
                                    @unknown default:
                                        EmptyView()
                                            .frame(width: 300, height: 375)
                                    }
                                }
                                .padding()
                                
                                Text(movie.title)
                                    .font(.custom("RobotoSlab-Bold", size: 24))
                                    .foregroundStyle(Color.white)
                                    .padding()
                                
                                Button("Return Home") {
                                    // TODO: Navigate user home
                                }
                                .font(.custom("RobotoSlab-Bold", size: 30))
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.theaterRed)
                                .foregroundColor(Color.popcornYellow)
                                .cornerRadius(15)
                                .padding()
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .transition(.move(edge: .bottom))
            .animation(.easeInOut, value: showMatchOverlay)
        }
    }
}
//
//#Preview {
//    SessionView()
//}
