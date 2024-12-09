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
                        // TODO: Handle like logic here
                        Task {
                            try await firebaseManager.likeMovie(movieID: networkManager.movies[currentMovieIndex].id, sessionCode: sessionCode)
                            currentMovieIndex += 1
                        }
                    }) {
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
                    }
                    .padding(.trailing, 10)
                    
                    Button(action: {
                        // TODO: Handle dislike logic here
                        Task {
                            try await firebaseManager.dislikeMovie(movieID: networkManager.movies[currentMovieIndex].id, sessionCode: sessionCode)
                            currentMovieIndex += 1
                        }
                    }) {
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

            }
            .padding()
            .background(Color.backgroundNavy)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action : {
                        dismiss()
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
            .onAppear {
                Task {
                    await networkManager.loadMovies()
                }
            }
        }
    }
}
//
//#Preview {
//    SessionView()
//}
