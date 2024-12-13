//
//  MovieCard.swift
//  JustPick
//
//  Created by Julian on 12/12/24.
//

import SwiftUI

struct MovieCard: View {
    let url: URL?
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 300, height: 375)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 275, height: 375)
                    .clipped()
                    .cornerRadius(8)
                    .shadow(radius: 1)
            case .failure:
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 300, height: 375)
                    .cornerRadius(30)
            @unknown default:
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 300, height: 375)
                    .cornerRadius(10)
            }
        }
    }
}
