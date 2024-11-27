//
//  ContentView.swift
//  JustPick
//
//  Created by Julian on 11/26/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Image("sign")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                    Text("JustPick")
                        .font(.custom("AntonSC-Regular", size: 40))
                }
                
                Spacer()
                
                VStack(spacing: 25) { // Buttons Column
                    Button(action: {
                        print("Host button tapped")
                    }) {
                        Text("Host a Session")
                            .font(.custom("AfacadFlux-VariableFont_slnt,wght", size: 30))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.theaterRed)
                            .foregroundColor(Color.popcornYellow)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        print("Join button tapped")
                    }) {
                        Text("Join a Session")
                            .font(.custom("AfacadFlux-VariableFont_slnt,wght", size: 30))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.theaterRed)
                            .foregroundColor(Color.popcornYellow)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
                .offset(y: 200)
                
                Image("popcorn")
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea(edges: .bottom)
                    .offset(y: 300)
            }
            .padding()
            .background(Color.backgroundNavy)
        }
    }
}

#Preview {
    ContentView()
}
