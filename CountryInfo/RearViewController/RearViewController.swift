//
//  RearViewController.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit

class RearViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false;
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: REGION[ROW])
        
        print("RearViewController did load")
    }
    
}

extension RearViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return REGION.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = REGION[ROW]
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        cell.backgroundColor = UIColor.clearColor()
        
        cell.textLabel?.textColor = REGIONCOLOR
        cell.textLabel?.text = REGION[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var nextViewController: UIViewController!
        
        if indexPath.row == 0 {
            
            nextViewController = FrontViewController(nibName: "FrontViewController", bundle: nil)
            
        } else {
            
            nextViewController = CountryTableViewController(nibName: "CountryTableViewController", bundle: nil)
        }
        
        let navigationController = UINavigationController.init(rootViewController: nextViewController)
        self.revealViewController().pushFrontViewController(navigationController, animated: true)
        
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        ROW = indexPath.row
        print("row: \(ROW)")
        return indexPath
    }
}
