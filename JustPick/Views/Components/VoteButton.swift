//
//  VoteButton.swift
//  JustPick
//
//  Created by Julian on 12/12/24.
//

import SwiftUI

struct VoteButton: View {
    let isLike: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if #available(iOS 18.0, *) {
                Image(systemName: isLike ? "hand.thumbsup" : "hand.thumbsdown")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isLike ? Color.buttonGreen : Color.theaterRed)
                    )
                    .overlay(
                        Circle()
                            .stroke(isLike ? Color.borderGreen : Color.borderRed, lineWidth: 2)
                    )
                    .symbolEffect(.bounce, options: .repeat(4))
            } else {
                // iOS 17 fallback
                Image(systemName: isLike ? "hand.thumbsup" : "hand.thumbsdown")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isLike ? Color.buttonGreen : Color.theaterRed)
                    )
                    .overlay(
                        Circle()
                            .stroke(isLike ? Color.borderGreen : Color.borderRed, lineWidth: 2)
                    )
            }
        }
    }
}
