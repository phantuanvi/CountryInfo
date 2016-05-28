//
//  FrontViewController.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit

class FrontViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: slugs[row])
        
        let leftButtonItem = UIBarButtonItem.init(title: "Menu", style: UIBarButtonItemStyle.Done, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.navigationItem.title = menus[0]
        
        print("frontViewController View Did Load")
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCountrys[0].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = slugs[0]
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        
        cell.textLabel?.text = arrCountrys[0][indexPath.row].name
        
        return cell
    }
}
