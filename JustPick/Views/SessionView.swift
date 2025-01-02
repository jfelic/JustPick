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
    @State var selectedGenres: Set<String> = [] // Passed in from HostSessionView
    @State var participants: [User] = []
    @State var currentMovieIndex = 0
    @State var showToolBar = true
    @State private var showMatchOverlay = false
    @State private var matchedMovie: Movie? = nil
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.popcornYellow))
                            .scaleEffect(2)
                    } else {
                        MovieCard(url: networkManager.movies[currentMovieIndex].fullPosterPath)
                        
                        Text(networkManager.movies[currentMovieIndex].title)
                            .font(.custom("RobotoSlab-Bold", size: 25))
                            .foregroundStyle(Color.white)
                    }
                }
                
                Spacer()
                
                HStack {
                    
                    // Like button
                    VoteButton(isLike: true, action: {
                        Task {
                            try await firebaseManager.likeMovie(movieID: networkManager.movies[currentMovieIndex].id, sessionCode: sessionCode)
                            currentMovieIndex += 1
                            
                            if currentMovieIndex >= networkManager.movies.count - 5 {
                                await networkManager.fetchNextPage(selectedGenres: selectedGenres, genres: ["Action": 28, "Adventure": 12, "Comedy": 35, "Drama": 18, "Fantasy": 14, "Horror": 27, "Mystery": 9648, "Romance": 10749, "Science Fiction": 878, "Thriller": 53])
                            }
                        }
                    })
                    .padding(.trailing)
                    
                    // Dislike button
                    VoteButton(isLike: false, action: {
                        Task {
                            try await firebaseManager.dislikeMovie(movieID: networkManager.movies[currentMovieIndex].id, sessionCode: sessionCode)
                            currentMovieIndex += 1
                            
                            if currentMovieIndex >= networkManager.movies.count - 5 {
                                await networkManager.fetchNextPage(selectedGenres: selectedGenres, genres: ["Action": 28, "Adventure": 12, "Comedy": 35, "Drama": 18, "Fantasy": 14, "Horror": 27, "Mystery": 9648, "Romance": 10749, "Science Fiction": 878, "Thriller": 53])
                            }
                        }
                    })
                    .padding(.leading)
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
                                // 1. Dismiss View
                                dismiss()
                                
                                // 2. Remove user from session
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
                        await networkManager.loadMovies(selectedGenres: selectedGenres, genres: ["Action": 28, "Adventure": 12, "Comedy": 35, "Drama": 18, "Fantasy": 14, "Horror": 27, "Mystery": 9648, "Romance": 10749, "Science Fiction": 878, "Thriller": 53])
                        isLoading = false
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
                        MatchOverlay(matchedMovie: matchedMovie)
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
