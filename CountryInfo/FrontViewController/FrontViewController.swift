//
//  FrontViewController.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit
import SafariServices
import CoreData
import Alamofire
import SwiftyJSON
import SVProgressHUD

class FrontViewController: UITableViewController {
    
    var countrys = [NSManagedObject]()
    
    var arrJSON: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("frontViewController View Did Load")
        
        let standardDefaults = NSUserDefaults.standardUserDefaults()
        let firstTime = standardDefaults.boolForKey("FirstTime")
        
        if firstTime {
            if (Reachability.isConnectedToNetwork() == true) {
                getDataFromLink()
                standardDefaults.setBool(false, forKey: "FirstTime")
                standardDefaults.synchronize()
            } else {
                let alertController = UIAlertController(title: "No Internet Connnection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
        tableView.registerNib(UINib(nibName: "CountryCell", bundle: nil), forCellReuseIdentifier: menus[row])
        
        let leftButtonItem = UIBarButtonItem.init(title: "Menu", style: UIBarButtonItemStyle.Done, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.navigationItem.title = menus[0]
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countrys.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = menus[0]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CountryCell
        
        // Configure the cell...
        
        let country = countrys[indexPath.row]
        
        cell.configureCell(country)
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let country = countrys[indexPath.row]
        let countryName = country.valueForKey("name") as! String
        let shortCountryName = countryName.replace(" ", replacement: "%20")
        
        let link = "https://en.wikipedia.org/wiki/\(shortCountryName)"
        
        print(link)
        let svc = SFSafariViewController(URL: NSURL(string: link)!)
        self.presentViewController(svc, animated: true, completion: nil)
    }
    
    func getDataFromLink() {
        
        if Reachability.isConnectedToNetwork() == true {
            SVProgressHUD.showWithStatus("Please wait!")
            
            Alamofire.request(.GET, "https://restcountries.eu/rest/v1/all").responseJSON { response in
                switch response.result {
                case .Success:
                    
                    if let value = response.result.value {
                        self.arrJSON = JSON(value)
                    }
                    self.parseJson()
                    
                case .Failure(let error):
                    print(error.description)
                }
            }
        }
        
    }
    
    func parseJson() {
        
        for i in 0..<arrJSON.count {
            var dict = arrJSON[i]
            
            // Save data to CoreData
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let entity = NSEntityDescription.entityForName("Country", inManagedObjectContext: managedContext)
            let country = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            country.setValue(dict["name"].stringValue, forKey: "name")
            
            let alphaCode = dict["alpha2Code"].stringValue.lowercaseString
            country.setValue(alphaCode, forKey: "alpha2Code")
            country.setValue(dict["population"].stringValue, forKey: "population")
            country.setValue(dict["area"].stringValue, forKey: "area")
            country.setValue(dict["region"].stringValue, forKey: "region")
            
            let urlString = "https://raw.githubusercontent.com/hjnilsson/country-flags/master/png250px/\(alphaCode).png"
            country.setValue(urlString, forKey: "flagUrl")
            
            do {
                try country.managedObjectContext?.save()
                //countrys.append(country)
            } catch let error as NSError{
                print("Could not save \(error), \(error.userInfo)")
            }
            
        }
        
        print("parse json and save to CoreData done !")
        
        SVProgressHUD.showSuccessWithStatus("Complete")
        SVProgressHUD.dismissWithDelay(0.5)
        fetchData()
        self.tableView.reloadData()
    }
    
    func fetchData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Country")
        
        // Create Predicate
        let predicate = NSPredicate(format: "%K == %@", "region", "Africa")
        fetchRequest.predicate = predicate
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            countrys = results as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

extension String {
    func replace(string: String, replacement: String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
