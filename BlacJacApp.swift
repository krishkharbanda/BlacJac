//
//  BlacJacApp.swift
//  BlacJac
//
//  Created by Krish on 12/27/22.
//

import SwiftUI

@main
struct BlacJacApp: App {
    
    @StateObject var brain = Brain()
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                GlobalView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .environmentObject(brain)
                GeometryReader { proxy in
                    let size = proxy.size
                    DynamicIsland(size: size)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .environmentObject(brain)
                }
                .ignoresSafeArea()
            }
        }
    }
}
