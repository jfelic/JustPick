//
//  JoinSessionView.swift
//  JustPick
//
//  Created by Julian on 12/1/24.
//

import SwiftUI

struct JoinSessionView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var nameText = ""
    @State var codeText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                
                CustomTextField(label: "Your Name: ", text: $nameText)
                CustomTextField(label: "Session Code: ", text: $codeText)
                
                Spacer()
                
                Button(action: {
                    print("JoinSessionView: Join Pressed")
                    // TODO: Handle logic here
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

