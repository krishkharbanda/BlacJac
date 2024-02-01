//
//  Brain.swift
//  BlacJac
//
//  Created by Krish on 12/27/22.
//

import Foundation
import SwiftUI
import MultipeerConnectivity

class Brain: ObservableObject {
    
    @Published var username = String()
    
    @Published var appScene: AppScene = .start
    
    @Published var inviteState: FindView.InviteState = .join
    @Published var session: MultipeerSession?
    @Published var host = String()
    
    @Published var deck: [PlayingCard.Suit: [Int]] = [.spades: Array(1...13), .clubs: Array(1...13), .hearts: Array(1...13), .diamonds: Array(1...13)]

    @Published var chipPool = 0
    @Published var playerBet = Int()
    
    @Published var playerHand = [PlayingCard]()
    @Published var playerAceIndexes = [Int]()
    @Published var dealerHand = [PlayingCard]()
    
    @Published var playerTurns = [Turn]()
    @Published var playerOrder = [MCPeerID]()
    @Published var playerTurn = false
    
    @Published var dealerWinStatus: WinStatus = .inPlay
    var playerWinStatus: WinStatus {
        if let lastTurn = playerTurns.last {
            if lastTurn.play == .stay {
                if playerTotal > 21 {
                    return .bust
                }
                else if dealerTotal >= 17 {
                    if playerTotal > dealerTotal {
                        return .win
                    } else if playerTotal == dealerTotal {
                        return .tie
                    } else {
                        return .loss
                    }
                } else {
                    return .inPlay
                }
            } else {
                return .inPlay
            }
        }
        return .inPlay
    }
    
    var playerTotal: Int {
        var total = 0
        for card in playerHand {
            total += card.cardValue
            print(total)
        }
        return total
    }
    var dealerTotal: Int {
        var total = 0
        for card in dealerHand {
            total += card.cardValue
        }
        return total
    }

    func dealRandom() -> PlayingCard {
        let suitNum = Int.random(in: 0..<4)
        var suit: PlayingCard.Suit {
            switch suitNum {
            case 0:
                return .spades
            case 1:
                return .clubs
            case 2:
                return .hearts
            case 3:
                return .diamonds
            default:
                fatalError("Suit does not exist.")
            }
        }
        let num = deck[suit]!.randomElement()
        guard let index = deck[suit]!.firstIndex(of: num!) else { fatalError("Card does not exist.") }
        deck[suit]!.remove(at: index)
        return PlayingCard(rank: num!, suit: suit)
    }

    func play(bet: Int, play: Turn.Play) -> Turn {
        if play == .hit {
            let card = dealRandom()
            playerHand.append(card)
            if card.rank == 1 {
                playerAceIndexes.append(playerHand.count-1)
            }
        }
        return Turn(bet: bet, play: play)
    }
    
    func dealerTurn() {
        while dealerTotal < 17 {
            dealerHand.append(dealRandom())
        }
    }
     
    enum WinStatus: String, CaseIterable {
        case win = "Win"
        case loss = "Loss"
        case tie = "Tie"
        case bust = "Bust"
        case inPlay = "In Play"
    }
}
