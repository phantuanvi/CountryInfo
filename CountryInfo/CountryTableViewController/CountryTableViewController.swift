//
//  CountryTableViewController.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit
import SafariServices

class CountryTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "CountryCell", bundle: nil), forCellReuseIdentifier: menus[row])
        
        self.navigationItem.title = menus[row]
        let leftButtonItem = UIBarButtonItem.init(title: "Menu", style: UIBarButtonItemStyle.Done, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrCountrys[row].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = menus[row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CountryCell

        // Configure the cell...
        
        let country = arrCountrys[row][indexPath.row]
        
        cell.configureCell(country)
        cell.backgroundColor = UIColor.clearColor()

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let country = arrCountrys[row][indexPath.row]
        let countryName = country.name.replace(" ", replacement: "%20")
        let link = "https://en.wikipedia.org/wiki/\(countryName)"
        print(link)
        let svc = SFSafariViewController(URL: NSURL(string: link)!)
        self.presentViewController(svc, animated: true, completion: nil)
    }
}
