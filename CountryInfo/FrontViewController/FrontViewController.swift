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
        
        NotificationCenter.default.addObserver(self, selector: #selector(FrontViewController.reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        reachabilityStatusChanged()
        
        tableView.backgroundColor = MAINCOLOR
        tableView.separatorColor = CELLSEPARATOR
        tableView.register(UINib(nibName: "CountryCell", bundle: nil), forCellReuseIdentifier: REGION[ROW])
        
        let leftButtonItem = UIBarButtonItem.init(title: "Region", style: UIBarButtonItemStyle.done, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = leftButtonItem
        leftButtonItem.tintColor = BUTTONCOLOR
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.navigationItem.title = REGION[ROW]
        
        // Initialize and configuration to the search controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search here..."
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = MAINCOLOR
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchfromCoreData()
    }

    // MARK: UITableViewDelegate, DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray.count
        } else {
            return countries.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = REGION[ROW]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CountryCell
        
        // Configure the cell...
        var country: NSManagedObject!
        
        if shouldShowSearchResults {
            country = filteredArray[indexPath.row]
        } else {
            country = countries[indexPath.row]
        }
        cell.configureCell(country)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if reachabilityStatus != NOACCESS {
            
            var country: NSManagedObject!
            if shouldShowSearchResults {
                country = filteredArray[indexPath.row]
            } else {
                country = countries[indexPath.row]
            }
            
            let countryName = country.value(forKey: "name") as! String
            let shortCountryName = countryName.replace(" ", replacement: "%20")
            
            let link = "https://en.wikipedia.org/wiki/\(shortCountryName)"
            print(link)
            let url = URL(string: link)
            if (url != nil) {
                let svc = SFSafariViewController(url: url!)
                self.present(svc, animated: true, completion: nil)
            }
        } else {
            let alertController = UIAlertController(title: "No Internet Connnection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchResultsUpdating delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text else {
            return
        }
        
        // Filter the data array and get only those countries that match the search text.
        filteredArray = countries.filter({(country) -> Bool in
         
            let countryText = country.value(forKey: "name") as! NSString
            
            return (countryText.range(of: searchString, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        // Reload the tableView
        tableView.reloadData()
    }
    
    // MARK: my func
    func getDataFromLink() {
        
        if reachabilityStatus != NOACCESS {
            SVProgressHUD.show(withStatus: "Please wait!")
            
            Alamofire.request("https://restcountries.eu/rest/v1/all").responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success:
                    
                    if let value = response.result.value {
                        self.arrJSON = JSON(value)
                    }
                    self.parseJson()
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
            
        }
        
    }
    
    func parseJson() {
        
        for i in 0..<arrJSON.count {
            var dict = arrJSON[i]
            
            // Save data to CoreData
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let entity = NSEntityDescription.entity(forEntityName: "Country", in: managedContext)
            let country = NSManagedObject(entity: entity!, insertInto: managedContext)
            
            country.setValue(dict["name"].stringValue, forKey: "name")
            
            let alphaCode = dict["alpha2Code"].stringValue.lowercased()
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
        SVProgressHUD.showSuccess(withStatus: "Complete")
        SVProgressHUD.dismiss(withDelay: 0.5)
        
        self.tableView.reloadData()
    }
    
    func fetchfromCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            countries = results as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @objc func reachabilityStatusChanged() {
        
        let standardDefaults = UserDefaults.standard
        let firstTime = standardDefaults.bool(forKey: "FirstTime")
        
        if ((firstTime) && (reachabilityStatus != NOACCESS)){
            
            getDataFromLink()
            standardDefaults.set(false, forKey: "FirstTime")
            standardDefaults.synchronize()
        }
        
        switch reachabilityStatus {
        case NOACCESS:
            
            // move back to Main Queue
            DispatchQueue.main.async(execute: { 
                let alert = UIAlertController(title: "No Internet Access", message: "Please make sure you are connected to the Internet", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    print("OK")
                })
                
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            })
        default:
            fetchfromCoreData()
        }
    }
    
    // Is called just as the object is about to be deallocated
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
    }
}

extension String {
    func replace(_ string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
}
