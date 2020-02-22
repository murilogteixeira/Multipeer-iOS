//
//  Message.swift
//  multipeerTeste
//
//  Created by Murilo Teixeira on 10/12/19.
//  Copyright © 2019 Murilo Teixeira. All rights reserved.
//

import Foundation

struct Message: Codable {
    let body: String
}

extension Device {
    func send(text: String) throws {
        let message = Message(body: text)
        let payload = try JSONEncoder().encode(message)
        try self.session?.send(payload, toPeers: [self.peerID], with: .reliable)
    }
}
