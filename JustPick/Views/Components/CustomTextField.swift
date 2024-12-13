//
//  CustomTextField.swift
//  JustPick
//
//  Created by Julian on 12/2/24.
//

import SwiftUI

struct CustomTextField: View {
    
    let label: String
    @Binding var text: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.custom("RobotoSlab-Bold", size: 18))
                .foregroundStyle(Color.theaterRed)
            
            
            TextField("", text: $text)
                .font(.custom("RobotoSlab-Regular", size: 18))
                .padding()
                .foregroundStyle(Color.backgroundNavy)
                .border(.primary)
                .background(Color.white)
                .cornerRadius(10)
                .overlay (
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.popcornYellow, lineWidth: 3)
            )
        }
    }
    
}
