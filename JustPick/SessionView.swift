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
    
    // Shared session info
    let sessionCode: String // Passed in from HostSessionView
    let sessionTitle: String // Passed in from HostSessionView
    @State var selectedGenres: Set<String> = ["Action"] // Passed in from HostSessionView
    @State var participants: [User] = []

    // Personal movie-viewing state
//    @State var currentMovieIndex = 0
//    @State var movies: [Movie] = [] // Populate this based on selectedGenres
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    Rectangle()
                        .frame(width: 300, height: 400)
                        .cornerRadius(10)
                    
                    Text("Movie Title")
                        .font(.custom("RobotoSlab-Bold", size: 25))
                        .foregroundStyle(Color.white)
                }
                
                Spacer()
                
                HStack {
                    Button(action: {
                        // TODO: Handle like logic here
                    }) {
                        Text("✅")
                    }
                    
                    Button(action: {
                        // TODO: Handle dislike logic here
                    }) {
                        Text("❌")
                    }
                }
                
                Spacer()
            
                ScrollView {
                    Text("Description: Lorem ipsum odor amet, consectetuer adipiscing elit. Leo adipiscing dui odio sem rutrum mus morbi. Vulputate primis placerat finibus sapien placerat ligula hendrerit. Cras vel imperdiet sagittis gravida in faucibus. Nostra quam dictumst parturient sociosqu ridiculus tristique. Porta placerat erat ipsum lectus diam; facilisis vitae consequat.")
                        .frame(maxWidth: .infinity)
                        .font(.custom("RobotoSlab-Bold", size: 18))
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
            .onAppear { // TODO: Get all the information we need from Firebase
                
            }
        }
    }
}
//
//#Preview {
//    SessionView()
//}
