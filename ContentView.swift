//
//  ContentView.swift
//  DynamicIslandTest
//
//  Created by Krish on 10/22/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var brain: Brain
    @State private var cards: [PlayingCard] = []
    @State private var showUsernameAlert = false
    @State private var username = String()
    @State private var inviteState: FindView.InviteState = .join
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                Image("Title")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 400)
                VStack {
                    Button {
                        inviteState = .host
                        showUsernameAlert = true
                    } label: {
                        ZStack {
                            Text("Host a Game")
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
                    Button {
                        inviteState = .join
                        showUsernameAlert = true
                    } label: {
                        ZStack {
                            Text("Join a Game")
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
                }
            }
            .padding()
        }
        .onAppear {
            NotificationCenter.default.post(name: .init("size"), object: NotificationModel(title: "Size", content: "size"))
        }
        .alert("Enter Username", isPresented: $showUsernameAlert) {
            TextField("Username", text: $username)
            
            Button("Continue") {
                brain.username = username
                brain.session = MultipeerSession(username: username)
                brain.inviteState = inviteState
                if inviteState == .host {
                    brain.appScene = .host
                } else {
                    brain.appScene = .join
                }
            }
            Button {
                
            } label: {
                Text("Cancel")
                    .foregroundColor(.red)
            }
        } message: {
            Text("Keep usernames between 1-15 characters.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
