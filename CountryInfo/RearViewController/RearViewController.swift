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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: REGION[ROW])
        
        tableView.backgroundColor = MAINCOLOR
        tableView.separatorColor = CELLSEPARATOR
        
        print("RearViewController did load")
    }
    
}

extension RearViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return REGION.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = REGION[ROW]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        cell.backgroundColor = UIColor.clear
        
        cell.textLabel?.textColor = BUTTONCOLOR
        cell.textLabel?.text = REGION[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var nextViewController: UIViewController!
        
        if indexPath.row == 0 {
            
            nextViewController = FrontViewController(nibName: "FrontViewController", bundle: nil)
            
        } else {
            
            nextViewController = CountryTableViewController(nibName: "CountryTableViewController", bundle: nil)
        }
        
        let navigationController = UINavigationController.init(rootViewController: nextViewController)
        self.revealViewController().pushFrontViewController(navigationController, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        ROW = indexPath.row
        print("row: \(ROW)")
        return indexPath
    }
}
