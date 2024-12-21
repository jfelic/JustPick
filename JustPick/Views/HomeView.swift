//
//  ContentView.swift
//  JustPick
//
//  Created by Julian on 11/26/24.
//

import SwiftUI

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                ZStack {
                    Image("sign")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                    Text("JustPick")
                        .font(.custom("AntonSC-Regular", size: 40))
                        .foregroundStyle(Color.black)
                }
                
                Spacer()
                
                VStack(spacing: 25) { // Buttons Column
                    NavigationLink(destination: HostSessionView()) {
                        Text("Host a Session")
                            .font(.custom("RobotoSlab-Bold", size: 30))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.theaterRed)
                            .foregroundColor(Color.popcornYellow)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    NavigationLink(destination: JoinSessionView()){
                        Text("Join a Session")
                            .font(.custom("RobotoSlab-Bold", size: 30))
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
                    .offset(y: 275)
            }
            .padding()
            .background(Color.backgroundNavy)
        }
        // TODO: 
//        .environment(\.navigationPath, $navigationPath)
    }
}

//#Preview {
//    HomeView()
//}
