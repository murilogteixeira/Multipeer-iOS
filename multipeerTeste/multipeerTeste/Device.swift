//
//  Device.swift
//  multipeerTeste
//
//  Created by Murilo Teixeira on 10/12/19.
//  Copyright © 2019 Murilo Teixeira. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Device: NSObject {
    let peerID: MCPeerID
    var session: MCSession?
    var name: String
    var state = MCSessionState.notConnected
    var lastMessageReceived: Message?
    
    init(peerID: MCPeerID) {
        self.name = peerID.displayName
        self.peerID = peerID
        super.init()
    }
    
    func connect() {
        if self.session != nil { return }
        
        self.session = MCSession(peer: MPCManager.instance.localPeerID, securityIdentity: nil, encryptionPreference: .required)
        self.session?.delegate = self
    }
    
    func disconnect() {
        self.session?.disconnect()
        self.session = nil
    }
    
    func invite(with browser: MCNearbyServiceBrowser) {
        self.connect()
        browser.invitePeer(self.peerID, to: self.session!, withContext: nil, timeout: 10)
    }
}

extension Device: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.state = state
        NotificationCenter.default.post(name: MPCManager.Notifications.deviceDidChangeState, object: self)
    }
    
    static let messageReceivedNotification = Notification.Name("DeviceDidReceivedMessage")
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let message = try? JSONDecoder().decode(Message.self, from: data) {
            self.lastMessageReceived = message
            NotificationCenter.default.post(name: Device.messageReceivedNotification, object: message, userInfo: ["from": self])
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}
