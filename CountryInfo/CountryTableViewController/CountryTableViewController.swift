//
//  CountryTableViewController.swift
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

class CountryTableViewController: UITableViewController {
    
    var countries = [NSManagedObject]()
    var arrJSON: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FrontViewController.reachabilityStatusChanged), name: "ReachStatusChanged", object: nil)
        reachabilityStatusChanged()

        tableView.backgroundColor = MAINCOLOR
        tableView.separatorColor = CELLSEPARATOR
        tableView.registerNib(UINib(nibName: "CountryCell", bundle: nil), forCellReuseIdentifier: REGION[ROW])
        
        self.navigationItem.title = REGION[ROW]
        let leftButtonItem = UIBarButtonItem.init(title: "Region", style: UIBarButtonItemStyle.Done, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        leftButtonItem.tintColor = BUTTONCOLOR
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchfromCoreData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return countries.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = REGION[ROW]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CountryCell

        // Configure the cell...
        
        let country = countries[indexPath.row]
        
        cell.configureCell(country)
        cell.backgroundColor = UIColor.clearColor()

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if reachabilityStatus != NOACCESS {
            let country = countries[indexPath.row]
            let countryName = country.valueForKey("name") as! String
            let shortCountryName = countryName.replace(" ", replacement: "%20")
            
            let link = "https://en.wikipedia.org/wiki/\(shortCountryName)"
            print(link)
            let url = NSURL(string: link)
            if (url != nil) {
                let svc = SFSafariViewController(URL: url!)
                self.presentViewController(svc, animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "No Internet Connnection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: my func
    
    func getDataFromLink() {
        
        if reachabilityStatus != NOACCESS {
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
        
        fetchfromCoreData()
        SVProgressHUD.showSuccessWithStatus("Complete")
        SVProgressHUD.dismissWithDelay(0.5)
        
        self.tableView.reloadData()
    }
    
    func reachabilityStatusChanged() {
        
        let standardDefaults = NSUserDefaults.standardUserDefaults()
        let firstTime = standardDefaults.boolForKey("FirstTime")
        
        if ((firstTime) && (reachabilityStatus != NOACCESS)){
            
            getDataFromLink()
            standardDefaults.setBool(false, forKey: "FirstTime")
            standardDefaults.synchronize()
        }
        
        switch reachabilityStatus {
        case NOACCESS:
            
            // move back to Main Queue
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertController(title: "No Internet Access", message: "Please make sure you are connected to the Internet", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                    print("OK")
                })
                
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
            })
        default:
            fetchfromCoreData()
        }
    }
    
    func fetchfromCoreData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Country")
        
        // Create Predicate
        let predicate = NSPredicate(format: "%K == %@", "region", REGION[ROW])
        fetchRequest.predicate = predicate
        
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            print(results)
            countries = results as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // Is called just as the object is about to be deallocated
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ReachStatusChanged", object: nil)
    }
    
}
