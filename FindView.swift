//
//  FindView.swift
//  DynamicIslandTest
//
//  Created by Krish on 12/7/22.
//

import SwiftUI
import os
import MultipeerConnectivity

struct FindView: View {
    
    @EnvironmentObject var brain: Brain
    var inviteState: InviteState
    @StateObject var multipeerSession: MultipeerSession
    @State private var done = false
    @State private var connectedOrder = [MCPeerID]()
    @State private var playersList = [String]()
    var logger = Logger()
    
    var body: some View {
        NavigationStack {
            if inviteState == .host {
                VStack {
                    Text("Available Players")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    List {
                        ForEach($playersList, id: \.self, editActions: .move) { $peer in
                            Button {
                                if !peer.isConnected {
                                    multipeerSession.serviceBrowser.invitePeer(peer.mcPeerID(state: .available)!, to: multipeerSession.session, withContext: nil, timeout: 30)
                                }
                            } label: {
                                HStack {
                                    Text(peer)
                                        .foregroundColor(.red)
                                    if peer.isConnected {
                                        Spacer()
                                        Image(systemName: "checkmark.circle")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .onMove(perform: move)
                    }
                    .toolbar {
                        EditButton()
                    }
                    Button {
                        brain.playerOrder = [multipeerSession.myPeerID]
                        brain.playerOrder += connectedOrder
                        NotificationCenter.default.post(name: .init("change"), object: NotificationModel(title: "Start Game", content: "deal"))
                        done = true
                        NotificationCenter.default.post(name: .init("appScene"), object: NotificationModel(title: "Continue", content: "game"))
                    } label: {
                        Text("Start Game")
                            .font(.system(.title3))
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical)
                            .clipped()
                            .background(.black)
                            .cornerRadius(30)
                    }
                }
                .onChange(of: multipeerSession.session.connectedPeers) { newValue in
                    let diff = connectedOrder.difference(from: multipeerSession.session.connectedPeers)
                    connectedOrder += diff
                }
                .onChange(of: connectedOrder) { newValue in
                    let both = connectedOrder + multipeerSession.availablePeers
                    playersList = both.map { $0.displayName }
                }
                .onChange(of: multipeerSession.availablePeers) { newValue in
                    let both = connectedOrder + multipeerSession.availablePeers
                    playersList = both.map { $0.displayName }
                }
            }
            else if (!multipeerSession.paired) {
                if inviteState == .join {
                    VStack {
                        Text("Waiting to Join")
                            .font(.largeTitle)
                            .bold()
                        Image("JustTitle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 350)
                            .padding(.horizontal, 100)
                        Text("An alert will pop up when a host sends an invite for you to join their game. Make sure to check the username before clicking 'Join Game'.")
                            .font(.title3)
                            .padding(.horizontal, 100)
                            .opacity(0.65)
                            .multilineTextAlignment(.center)
                    }
                    .alert("Received an invite from \(multipeerSession.recvdInviteFrom?.displayName ?? "ERR")!", isPresented: $multipeerSession.recvdInvite) {
                        Button("Join Game") {
                            if (multipeerSession.invitationHandler != nil) {
                                multipeerSession.invitationHandler!(true, multipeerSession.session)
                                done = true
                                NotificationCenter.default.post(name: .init("appScene"), object: NotificationModel(title: "Continue", content: "game"))
                            }
                        }
                        Button("Reject Invite") {
                            if (multipeerSession.invitationHandler != nil) {
                                multipeerSession.invitationHandler!(false, nil)
                            }
                        }
                    }
                }
            }
            if done {
                Color.white
            }
        }
    }
    
    enum InviteState {
        case host
        case join
    }
    
    func move(from source: IndexSet, to destination: Int) {
        playersList.move(fromOffsets: source, toOffset: destination)
        let connectedVals = playersList.filter { $0.isConnected }
        connectedOrder = connectedVals.map { $0.mcPeerID(state: .connected)! }
        print(connectedOrder)
    }
}
