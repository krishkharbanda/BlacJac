//
//  GlobalView.swift
//  DynamicIslandTest
//
//  Created by Krish on 11/22/22.
//

import SwiftUI

struct GlobalView: View {
    
    @EnvironmentObject var brain: Brain
    
    var body: some View {
        ZStack {
            if brain.appScene == .start {
                ContentView()
                    .environmentObject(brain)
            } else if brain.appScene == .host {
                FindView(inviteState: .host, multipeerSession: brain.session!)
                    .environmentObject(brain)
            } else if brain.appScene == .join {
                FindView(inviteState: .join, multipeerSession: brain.session!)
                    .environmentObject(brain)
            } else if brain.appScene == .game {
                GameView()
                    .environmentObject(brain)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("refresh"))) { output in
            guard let notification = output.object as? NotificationModel else { return }
            print(notification.content)
        }
    }
}

struct GlobalView_Previews: PreviewProvider {
    static var previews: some View {
        GlobalView()
    }
}
