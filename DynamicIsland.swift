//
//  DynamicIsland.swift
//  DynamicIslandTest
//
//  Created by Krish on 10/22/22.
//

import SwiftUI

var size: CGSize?

struct DynamicIsland: View {
    
    @EnvironmentObject var brain: Brain
    @State var size: CGSize
    @State var isExpanded: Bool = false
    @State var notification: NotificationModel?
    @State var dealerHand: [PlayingCard] = []
    @State var face: Face = .back
    
    var body: some View {
        ZStack {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: isExpanded ? 50 : 63, style: .continuous)
                    .frame(width: isExpanded ? size.width - 22 : 127, height: isExpanded ? 270 : 36)
                    .clipped()
                    .offset(y: 11)
                    .onReceive(NotificationCenter.default.publisher(for: .init("size")), perform: { output in
                        guard let notification = output.object as? NotificationModel else { return }
                        self.notification = notification
                        size = self.size
                        print(size)
                    })
                    .onReceive(NotificationCenter.default.publisher(for: .init("change"))) { output in
                        guard let notification = output.object as? NotificationModel else { return }
                        self.notification = notification
                        if notification.content == "deal" {
                            withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.7)) {
                                isExpanded.toggle()
                                if notification.content == "deal" {
                                    brain.dealerHand = [brain.dealRandom(), brain.dealRandom()]
                                    let string = "Start Game  \(String(brain.dealerHand[0].rank)) \(String(brain.dealerHand[0].suit.rawValue)) \(String(brain.dealerHand[1].rank)) \(String(brain.dealerHand[1].suit.rawValue))"
                                    print(string)
                                    brain.session!.send(message: string)
                                    brain.session!.send(message: "Turn: \(brain.playerOrder[0].displayName)")
                                    brain.playerTurn = true
                                    NotificationCenter.default.post(name: .init("refresh"), object: NotificationModel(title: "Start Game", content: "deal"))
                                }
                            }
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .init("flip"))) { output in
                        guard let notification = output.object as? NotificationModel else { return }
                        self.notification = notification
                        withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.7)) {
                            if face == .front {
                                face = .back
                            } else {
                                face = .front
                            }
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .init("refresh"))) { output in
                        guard let notification = output.object as? NotificationModel else { return }
                        self.notification = notification
                        withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.7, blendDuration: 0.7)) {
                            isExpanded = true
                            self.dealerHand = brain.dealerHand
                            print(brain.dealerHand)
                        }
                    }
                VStack {
                    Spacer()
                    VStack {
                        //3...5
                        if dealerHand.count > 3 {
                            HStack {
                                ForEach(3..<dealerHand.count, id: \.self) { i in
                                    if face == .front {
                                        DynamicCard(aspectRatio: 0.275, playingCard: dealerHand[i])
                                    } else {
                                        DynamicCardBack(aspectRatio: 0.275)
                                    }
                                }
                            }
                        }
                        //0...2
                        HStack {
                            ForEach(dealerHand.count > 3 ? (0..<3) : (0..<dealerHand.count), id: \.self) { i in
                                if face == .front {
                                    DynamicCard(aspectRatio: 0.275, playingCard: dealerHand[i])
                                } else {
                                    DynamicCardBack(aspectRatio: 0.275)
                                }
                            }
                        }
                    }
                    .frame(width: size.width - 33, height: 200)
                    .cornerRadius(50)
                    Text("Pool Total: \(brain.chipPool)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .opacity(isExpanded ? 1 : 0)
                .clipped()
            }
            .frame(width: isExpanded ? size.width - 22 : 127, height: isExpanded ? 270 : 36)
        }
    }
    
    enum Face {
        case front
        case back
    }
}

struct DynamicIsland_Previews: PreviewProvider {
    static var previews: some View {
        DynamicIsland(size: CGSize(width: 393, height: 300), isExpanded: true)
            .previewLayout(.sizeThatFits)
    }
}
struct NotificationModel {
    var title: String
    var content: String
}
