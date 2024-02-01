//
//  GameView.swift
//  DynamicIslandTest
//
//  Created by Krish on 11/22/22.
//

import SwiftUI

struct GameView: View {
    
    @EnvironmentObject var brain: Brain
    @State private var playerHand = [PlayingCard]()
    @State private var notification: NotificationModel?
    @State private var bet = 10
    @State private var playerDone = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .frame(width: (size ?? CGSize()).width - 22, height: 270)
                .clipped()
                .offset(y: 11)
            VStack (spacing: 20) {
                HStack {
                    Button {
                        bet -= 5
                    } label: {
                        Text("-")
                            .foregroundColor(bet != 0 ? .red : .gray)
                            .fontWeight(.medium)
                    }
                    .disabled(bet == 0)
                    Text("\(bet) Koin")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Button {
                        bet += 5
                    } label: {
                        Text("+")
                            .foregroundColor(bet != 50 ? .black : .gray)
                            .fontWeight(.medium)
                    }
                    .disabled(bet == 50)
                }
                Text("Card Total: \(brain.playerTotal)")
                    .font(.title3)
                    .fontWeight(.semibold)
                VStack {
                    //3...5
                    if playerHand.count > 3 {
                        HStack {
                            ForEach(3..<playerHand.count, id: \.self) { i in
                                DynamicCard(aspectRatio: 0.45, playingCard: playerHand[i])
                            }
                        }
                    }
                    //0...2
                    HStack {
                        ForEach(playerHand.count > 3 ? (0..<3) : (0..<playerHand.count), id: \.self) { i in
                            DynamicCard(aspectRatio: 0.45, playingCard: playerHand[i])
                        }
                    }
                }
                HStack {
                    Button {
                        brain.playerTurns.append(brain.play(bet: bet, play: .hit))
                        NotificationCenter.default.post(name: .init("refresh"), object: NotificationModel(title: "Player Turn", content: "hit"))
                        print(brain.playerHand)
                        if brain.playerTotal >= 21 {
                            playerDone = true
                        }
                        finishTurn()
                    } label: {
                        ZStack {
                            Text("Hit")
                                .font(.system(.title3))
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical)
                                .clipped()
                                .background(.black)
                                .cornerRadius(30)
                                .opacity((playerDone || !brain.playerTurn) ? 0.65:1)
                        }
                    }
                    Button {
                        brain.playerTurns.append(brain.play(bet: bet, play: .stay))
                        playerDone = true
                        finishTurn()
                    } label: {
                        ZStack {
                            Text("Stay")
                                .font(.system(.title3))
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical)
                                .clipped()
                                .background(.red)
                                .cornerRadius(30)
                                .opacity((playerDone || !brain.playerTurn) ? 0.65:1)
                        }
                    }
                }
                .disabled(playerDone || !brain.playerTurn)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("refresh"))) { output in
            guard let notification = output.object as? NotificationModel else { return }
            self.notification = notification
            withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.7)) {
                self.playerHand = brain.playerHand
            }
        }
        .onChange(of: playerDone) { newValue in
            if newValue {
                NotificationCenter.default.post(Notification(name: .init("flip"), object: NotificationModel(title: "Player Done", content: "dealer")))
            }
        }
        .onAppear {
            let hand = [brain.dealRandom(), brain.dealRandom()]
            brain.playerHand = hand
            playerHand = hand
        }
    }
    
    func finishTurn() {
        brain.playerTurn = false
        brain.chipPool += brain.playerTurns.last!.bet
        if brain.playerTurns.last!.play == .hit {
            brain.session!.send(message: "\(brain.username) Turn: \(String(describing: brain.playerTurns.last!.bet)) \(brain.playerHand.last!.rankString) \(brain.playerHand.last!.suit.rawValue)")
        } else {
             brain.session!.send(message: "\(brain.username) Turn: \(String(describing: brain.playerTurns.last!.bet)) Stay")
        }
        if brain.inviteState == .host {
            brain.session!.send(message: "Turn: \(brain.playerOrder[1].displayName)")
        }
    }
}
