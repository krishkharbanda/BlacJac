//
//  Structs.swift
//  DynamicIslandTest
//
//  Created by Krish on 11/22/22.
//

import Foundation
import SwiftUI

struct PlayingCard: Equatable {
    let rank: Int
    var rankString: String {
        switch rank {
        case 1:
            return "A"
        case 11:
            return "J"
        case 12:
            return "Q"
        case 13:
            return "K"
        default:
            return String(rank)
        }
    }
    let suit: Suit
    var suitColor: Color {
        switch suit {
        case .spades:
            return .black
        case .clubs:
            return .black
        case .hearts:
            return .red
        case .diamonds:
            return .red
        }
    }
    var cardValue = Int()
    
    init(rank: Int, suit: Suit) {
        self.rank = rank
        self.suit = suit
        switch rank {
        case 1:
            self.cardValue = 1
        case 11:
            self.cardValue = 10
        case 12:
            self.cardValue = 10
        case 13:
            self.cardValue = 10
        default:
            self.cardValue = rank
        }
    }
    
    enum Suit: String, CaseIterable {
        case spades = "suit.spade.fill"
        case clubs = "suit.club.fill"
        case hearts = "suit.heart.fill"
        case diamonds = "suit.diamond.fill"
    }
}
struct Turn {
    let bet: Int
    let play: Play
    enum Play {
        case hit
        case stay
    }
}
enum PeerState {
    case connected
    case available
}
