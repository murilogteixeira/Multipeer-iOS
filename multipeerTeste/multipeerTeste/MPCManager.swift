//
//  MPCManager.swift
//  multipeerTeste
//
//  Created by Murilo Teixeira on 10/12/19.
//  Copyright © 2019 Murilo Teixeira. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MPCManager: NSObject {
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    struct Notifications {
        static let deviceDidChangeState = Notification.Name("deviceDidChangeState")
    }
    
    static let instance = MPCManager()
    
    var localPeerID: MCPeerID
    let serviceType = "MPC-Testing"
    
    var devices: [Device] = []
    
    override init() {
        if let data = UserDefaults.standard.data(forKey: "peerID"),
            let id = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data) {
            self.localPeerID = id
        }
        else {
            let peerID = MCPeerID(displayName: UIDevice.current.name)
            let data = try? NSKeyedArchiver.archivedData(withRootObject: peerID, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: "peerID")
            self.localPeerID = peerID
        }
        
        super.init()
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: serviceType)
        self.advertiser.delegate = self
        
        self.browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: self.serviceType)
        self.browser.delegate = self
    }
    
    func device(for id: MCPeerID) -> Device {
        for device in self.devices {
            if device.peerID == id { return device }
        }
        
        let device = Device(peerID: id)
        
        self.devices.append(device)
        return device
    }
    
    func start() {
        self.advertiser.startAdvertisingPeer()
        self.browser.startBrowsingForPeers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enteredBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

    }
    
    @objc func enteredBackground() {
        for device in devices {
            device.disconnect()
        }
    }
}

extension MPCManager {
    var connectedDevices: [Device] {
        return self.devices.filter { $0.state == .connected }
    }
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let device = MPCManager.instance.device(for: peerID)
        device.connect()
        invitationHandler(true, device.session)
        //  Handle our incoming peer
    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let device = MPCManager.instance.device(for: peerID)
        device.invite(with: self.browser)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let device = MPCManager.instance.device(for: peerID)
        device.disconnect()
    }
}
