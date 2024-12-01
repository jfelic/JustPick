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
    @Environment(\.dismiss) var dismiss
    
    let genres = ["All", "Action", "Adventure", "Comedy", "Drama", "Fantasy", "Horror", "Mystery", "Romance", "Sci-Fi", "Thriller"]
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
                    
                    Text("Session Title: ")
                        .font(.custom("RobotoSlab-Bold", size: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.theaterRed)
                    
                    TextField("", text: $title)
                        .font(.custom("RobotoSlab-Regular", size: 18))
                        .padding([.top, .bottom, .horizontal])
                        .foregroundStyle(Color.backgroundNavy)
                        .border(.primary)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.popcornYellow, lineWidth: 3)
                        )
                    
                    Spacer()
                    
                    ScrollView {
                        VStack {
                            ForEach(genres, id: \.self) { genre in
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
                        print("Host Session pressed")
                        // Handle logic here
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
            }
            .onTapGesture { // Dismiss keyboard when user taps outside of it
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
            }
            .onAppear { // Generate session code
                sessionCode = String(Int.random(in: 1000...9999))
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

#Preview {
    HostSessionView()
}
