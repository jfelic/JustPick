//
//  JoinSessionView.swift
//  JustPick
//
//  Created by Julian on 12/1/24.
//

import SwiftUI

struct JoinSessionView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var navigateToSessionView = false // state to trigger navigation
    @State var name = ""
    @State var sessionCode = ""
    
    // States to store session details
    @State private var sessionTitle = ""
    @State private var selectedGenres: Set<String> = []
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                
                CustomTextField(label: "Your Name: ", text: $name)
                CustomTextField(label: "Session Code: ", text: $sessionCode)
                
                Spacer()
                
                Button(action: {
                    print("JoinSessionView: Join Pressed")
                    // TODO: Handle logic here
                    
                    Task {
                        do {
                            // First we sign in our user
                            await firebaseManager.signInAnonymously(name: name)
                            
                            // Then fetch session details
                            let details = try await firebaseManager.getSessionDetails(sessionCode: sessionCode)
                            
                            // Store details
                            sessionTitle = details.title
                            selectedGenres = details.selectedGenres
                            
                            // Add use to session
                            if let currentUser = firebaseManager.currentUser {
                                try await firebaseManager.addUserToSession(sessionCode: sessionCode, user: currentUser)
                            }
                            
                            // Navigate 👍
                            navigateToSessionView = true
                            
                        } catch {
                            showError = true
                            errorMessage = "Could not join session: \(error.localizedDescription)"
                        }
                    }
                    
                }) {
                    Text("Join Session")
                        .font(.custom("RobotoSlab-Bold", size: 30))
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.theaterRed)
                        .foregroundStyle(Color.popcornYellow)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                
                NavigationLink(
                    destination: SessionView(sessionCode: sessionCode, sessionTitle: sessionTitle),
                    isActive: $navigateToSessionView
                ) {
                    EmptyView()
                }
            }
            .padding()
            .background(Color.backgroundNavy)
            .navigationBarBackButtonHidden(true)
            .toolbar { // Our AppBar()
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
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    showError = false
                }
            } message: {
                Text(errorMessage)
            }
            .onTapGesture { // Dismiss keyboard when user taps outside of it
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
        }
    }
}

//#Preview {
//    JoinSessionView()
//}

