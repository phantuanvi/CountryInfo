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
        
        NotificationCenter.default.addObserver(self, selector: #selector(FrontViewController.reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        reachabilityStatusChanged()

        tableView.backgroundColor = MAINCOLOR
        tableView.separatorColor = CELLSEPARATOR
        tableView.register(UINib(nibName: "CountryCell", bundle: nil), forCellReuseIdentifier: REGION[ROW])
        
        self.navigationItem.title = REGION[ROW]
        let leftButtonItem = UIBarButtonItem.init(title: "Region", style: UIBarButtonItemStyle.done, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        leftButtonItem.tintColor = BUTTONCOLOR
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchfromCoreData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return countries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = REGION[ROW]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CountryCell

        // Configure the cell...
        
        let country = countries[indexPath.row]
        
        cell.configureCell(country)
        cell.backgroundColor = UIColor.clear

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reachabilityStatus != NOACCESS {
            let country = countries[indexPath.row]
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
    
    func reachabilityStatusChanged() {
        
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
    
    func fetchfromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        
        // Create Predicate
        let predicate = NSPredicate(format: "%K == %@", "region", REGION[ROW])
        fetchRequest.predicate = predicate
        
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            print(results)
            countries = results as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // Is called just as the object is about to be deallocated
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
    }
    
}
