//
//  NotificationVC.swift
//  DIPL
//
//  Created by Mario Ivankovic on 01/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NotificaionCell"

class NotificationVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear separator lines
        tableView.separatorColor = .clear
        
        // Nav title
        navigationItem.title = "Notifications"
        
        // Register cell class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        
        return cell
    }
}
