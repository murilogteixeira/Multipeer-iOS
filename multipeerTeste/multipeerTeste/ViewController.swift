//
//  ViewController.swift
//  multipeerTeste
//
//  Created by Murilo Teixeira on 10/12/19.
//  Copyright © 2019 Murilo Teixeira. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var devices: [Device] = []
    
    @objc func reload() {
        self.devices = Array(MPCManager.instance.devices).sorted(by: {$0.name < $1.name })
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: MPCManager.Notifications.deviceDidChangeState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: MPCManager.Notifications.deviceDidChangeState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Device.messageReceivedNotification, object: nil)
        
        self.reload()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let device = self.devices[indexPath.row]
        cell.textLabel?.text = "\(device.name) - \(device.state.rawValue)"
        cell.detailTextLabel?.text = device.lastMessageReceived?.body
        return cell
    }
}


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = self.devices[indexPath.row]
        let alert = UIAlertController(title: "Send To \(device.name)", message: "Enter your message:", preferredStyle: .alert)
        alert.addTextField { field in }
        
        alert.addAction(UIAlertAction(title: "Send", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                try? device.send(text: text)
            }
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
