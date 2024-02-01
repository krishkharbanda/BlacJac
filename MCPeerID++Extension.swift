//
//  MCPeerID++Extension.swift
//  DynamicIslandTest
//
//  Created by Krish on 12/25/22.
//

import Foundation
import MultipeerConnectivity

extension MCPeerID {
    var isConnected: Bool {
        var isConn = false
        for conPeer in brain.session!.session.connectedPeers {
            if conPeer.displayName == self.displayName {
                isConn = true
                break
            }
        }
        return isConn
    }
}
