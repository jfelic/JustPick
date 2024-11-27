//
//  ContentView.swift
//  JustPick
//
//  Created by Julian on 11/26/24.
//

import SwiftUI

struct ContentView: View {
    func signIn() -> Void{
        print("Hello")
    }
    
    var body: some View {
        VStack {
            
            Button(action: {
                print("Host button tapped")
            }) {
                Text("Host")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.green)
                    .foregroundColor(Color.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            
            Button(action: {
                print("Join button tapped")
            }) {
                Text("Join")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
