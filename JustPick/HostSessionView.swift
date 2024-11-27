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
        }
    }
}

#Preview {
    HostSessionView()
}
