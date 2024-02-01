//
//  MultipeerSession.swift
//  DynamicIslandTest
//
//  Created by Krish on 12/7/22.
//

import Foundation
import MultipeerConnectivity
import os

class MultipeerSession: NSObject, ObservableObject {
    private let serviceType = "blacjac-service"
    var myPeerID: MCPeerID
    
    public let serviceAdvertiser: MCNearbyServiceAdvertiser
    public let serviceBrowser: MCNearbyServiceBrowser
    public let session: MCSession
    
    private let log = Logger()
    
    @Published var availablePeers: [MCPeerID] = []
    @Published var recvdInvite: Bool = false
    @Published var recvdInviteFrom: MCPeerID? = nil
    @Published var paired: Bool = false
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    
    init(username: String) {
        let peerID = MCPeerID(displayName: username)
        self.myPeerID = peerID
        
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        super.init()
        
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    
    func send(message: String) {
        if !session.connectedPeers.isEmpty {
            log.info("sendMessage: \(message)")
            do {
                try session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                log.error("Error sending: \(String(describing: error))")
            }
        }
    }
}

extension MultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log.info("peer \(peerID) didChangeState: \(state.rawValue)")
        switch state {
        case MCSessionState.notConnected:
            DispatchQueue.main.async {
                self.paired = false
            }
            serviceAdvertiser.startAdvertisingPeer()
            break
        case MCSessionState.connected:
            DispatchQueue.main.async {
                self.paired = true
            }
            serviceAdvertiser.stopAdvertisingPeer()
            break
        default:
            DispatchQueue.main.async {
                self.paired = false
            }
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            if let string = String(data: data, encoding: .utf8) {
                print(string)
                var stringSplit = string.split(separator: Character(" "))
                if stringSplit[0] == "Start" && stringSplit[1] == "Game" {
                    self.log.info("Starting Game")
                    DispatchQueue.main.async {
                        print(string)
                        for i in 0..<2 {
                            print(stringSplit[2+(i*2)], stringSplit[3+(i*2)])
                            guard let rank = Int(stringSplit[2+(i*2)]), let suit = PlayingCard.Suit(rawValue: String(stringSplit[3+(i*2)])) else { break }
                            brain.dealerHand.append(PlayingCard(rank: rank, suit: suit))
                            print(brain.dealerHand)
                            if i == 1 {
                                NotificationCenter.default.post(name: .init("refresh"), object: NotificationModel(title: "Start Game", content: "start"))
                            }
                        }
                    }
                } else if stringSplit[0] == "Turn:" {
                    stringSplit.remove(at: 0)
                    print(stringSplit, stringSplit.joined(separator: " "))
                    if stringSplit.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines) == brain.username {
                        if (brain.playerTotal >= 21) || (brain.playerTurns.last?.play == .stay) {
                            self.send(message: "\(brain.username) Turn: 0 Stay")
                        } else {
                            brain.playerTurn = true
                            NotificationCenter.default.post(name: .init("refresh"), object: NotificationModel(title: "Turn", content: "me"))
                        }
                    }
                } else {
                    let last = String(stringSplit.last!)
                    if last == "Stay" {
                        guard let chipPool = Int(stringSplit[stringSplit.count - 2]) else { return }
                        brain.chipPool += chipPool
                    } else {
                        guard let chipPool = Int(stringSplit[stringSplit.count - 3]), let rank = Int(stringSplit[stringSplit.count - 2]), let suit = PlayingCard.Suit(rawValue: last) else { return }
                        brain.chipPool += chipPool
                        print(chipPool)
                        guard let index = brain.deck[suit]!.firstIndex(of: rank) else { fatalError("Card does not exist.") }
                        print(index)
                        brain.deck[suit]!.remove(at: index)
                        self.log.info("didReceive turn \(string)")
                    }
                    if brain.inviteState == .host {
                        var username = String(stringSplit.first!)
                        for i in 0..<(stringSplit.count - 4) {
                            let str = String(stringSplit[i])
                            if str != "Turn:" {
                                username += " " + str
                            }
                        }
                        if let peer = username.mcPeerID(state: .connected) {
                            if peer == brain.playerOrder.last! {
                                self.send(message: "Turn: \(brain.playerOrder[0].displayName)")
                            } else {
                                self.send(message: "Turn: \(brain.playerOrder[brain.playerOrder.firstIndex(of: peer)! + 1].displayName)")
                            }
                        }
                    }
                }
            } else {
                self.log.info("didReceive invalid value \(data.count) bytes")
            }
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log.error("Receiving streams is not supported")
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log.error("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        log.error("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log.error("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        log.info("didReceiveInvitationFromPeer \(peerID)")
        
        DispatchQueue.main.async {
            self.recvdInvite = true
            self.recvdInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        log.error("ServiceBroser didNotStartBrowsingForPeers: \(String(describing: error))")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        log.info("ServiceBrowser found peer: \(peerID)")
        DispatchQueue.main.async {
            self.availablePeers.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("ServiceBrowser lost peer: \(peerID)")
        DispatchQueue.main.async {
            self.availablePeers.removeAll(where: {
                $0 == peerID
            })
        }
    }
}
