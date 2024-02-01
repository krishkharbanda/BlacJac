//
//  String++Extension.swift
//  DynamicIslandTest
//
//  Created by Krish on 12/25/22.
//

import Foundation
import MultipeerConnectivity

extension String {
    var isConnected: Bool {
        var isConn = false
        for conPeer in brain.session!.session.connectedPeers {
            if conPeer.displayName == self {
                isConn = true
                break
            }
        }
        return isConn
    }
    
    func mcPeerID(state: PeerState) -> MCPeerID? {
        var peer: MCPeerID?
        if self == brain.username {
            return brain.session!.myPeerID
        }
        switch state {
        case .connected:
            let index = brain.session!.session.connectedPeers.firstIndex { $0.displayName == self }
            peer = brain.session!.session.connectedPeers[index!]
        case .available:
            let index = brain.session!.availablePeers.firstIndex { $0.displayName == self }
            peer = brain.session!.availablePeers[index!]
        }
        return peer
    }
}
