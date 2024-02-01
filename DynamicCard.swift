//
//  DynamicCard.swift
//  DynamicIslandTest
//
//  Created by Krish on 10/24/22.
//

import SwiftUI

struct DynamicCard: View {
    
    @State var aspectRatio: CGFloat = 1
    @State var frame = CGSize(width: 250, height: 350)
    @State var playingCard: PlayingCard
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25 * aspectRatio)
                .frame(width: frame.width * aspectRatio, height: frame.height * aspectRatio)
                .foregroundColor(.white)
                .shadow(radius: 3)
            VStack {
                HStack {
                    Text(playingCard.rankString)
                        .font(.system(size: 30 * aspectRatio, weight: .bold))
                        .padding(.vertical, 20 * aspectRatio)
                        .padding(.horizontal, 22 * aspectRatio)
                        .foregroundColor(playingCard.suitColor)
                    Spacer()
                }
                Spacer()
                Image(systemName: playingCard.suit.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60 * aspectRatio, height: 60 * aspectRatio)
                    .foregroundColor(playingCard.suitColor)
                Spacer()
                HStack {
                    Spacer()
                    Text(playingCard.rankString)
                        .font(.system(size: 30 * aspectRatio, weight: .bold))
                        .padding(.vertical, 20 * aspectRatio)
                        .padding(.horizontal, 22 * aspectRatio)
                        .foregroundColor(playingCard.suitColor)
                }
            }
        }
        .frame(width: frame.width * aspectRatio, height: frame.height * aspectRatio)
    }
}

struct DynamicCardBack: View {
    
    @State var aspectRatio: CGFloat = 1
    @State var frame = CGSize(width: 250, height: 350)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25 * aspectRatio)
                .frame(width: frame.width * aspectRatio, height: frame.height * aspectRatio)
                .foregroundColor(.white)
                .shadow(radius: 3)
            Image("Title")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200 * aspectRatio)
                .clipped()
        }
    }
}

struct DynamicCard_Previews: PreviewProvider {
    static var previews: some View {
        DynamicCard(aspectRatio: 0.75, playingCard: PlayingCard(rank: 1, suit: .spades))
    }
}
