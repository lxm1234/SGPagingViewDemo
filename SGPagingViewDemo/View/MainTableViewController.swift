//
//  MainTableViewController.swift
//  SGPagingViewDemo
//
//  Created by Apple on 2018/4/11.
//  Copyright © 2018年 Apple. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    let dataSource :[String] = ["静止样式"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let vc = DefaultStaticViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
