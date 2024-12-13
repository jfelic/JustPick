//
//  MatchOverlay.swift
//  JustPick
//
//  Created by Julian on 12/13/24.
//
import SwiftUI

struct MatchOverlay: View {
    let matchedMovie: Movie? 
    
    var body: some View {
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
                    MovieCard(url: movie.fullPosterPath)
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
