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

class FrontViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var countries = [NSManagedObject]()
    
    var filteredArray = [NSManagedObject]()
    var searchController: UISearchController!
    var shouldShowSearchResults = false
    
    var arrJSON: JSON!
    
    // MARK: viewController's lifecyle
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
        
        let leftButtonItem = UIBarButtonItem.init(title: "Region", style: UIBarButtonItemStyle.Done, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.navigationItem.title = menus[0]
        
        // Initialize and configuration to the search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor(red: 226.0/255.0, green: 236.0/255.0, blue: 136.0/255.0, alpha: 1)
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }

    // MARK: UITableViewDelegate, DataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray.count
        } else {
            return countries.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = menus[row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CountryCell
        
        // Configure the cell...
        var country: NSManagedObject!
        
        if shouldShowSearchResults {
            country = filteredArray[indexPath.row]
        } else {
            country = countries[indexPath.row]
        }
        cell.configureCell(country)
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if Reachability.isConnectedToNetwork() {
            let country = countries[indexPath.row]
            let countryName = country.valueForKey("name") as! String
            let shortCountryName = countryName.replace(" ", replacement: "%20")
            
            let link = "https://en.wikipedia.org/wiki/\(shortCountryName)"
            
            print(link)
            let svc = SFSafariViewController(URL: NSURL(string: link)!)
            self.presentViewController(svc, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "No Internet Connnection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: UISearchBarDelegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchResultsUpdating delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else {
            return
        }
        
        // Filter the data array and get only those countries that match the search text.
        filteredArray = countries.filter({(country) -> Bool in
         
            let countryText = country.valueForKey("name") as! NSString
            
            return (countryText.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        // Reload the tableView
        tableView.reloadData()
    }
    
    // MARK: my func
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
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            countries = results as! [NSManagedObject]
            
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
