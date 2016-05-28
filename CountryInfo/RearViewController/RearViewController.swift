//
//  RearViewController.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit

let menus = ["Africa", "Asia", "Central America and Mexico", "Eastern Europe and Central Asia", "North Africa and the Middle East", "Pacific Islands", "South America", "The Caribbean"]
let slugs = ["africa", "asia", "centralamerica", "easteurope", "northafr", "pacificislands", "southamerica", "caribbean"]
var row: Int!

class RearViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "regionsCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension RearViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "regionsCell"
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)!
        
        cell.textLabel?.text = menus[indexPath.row]
        
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
        row = indexPath.row
        print("row: \(row)")
        return indexPath
    }
}
