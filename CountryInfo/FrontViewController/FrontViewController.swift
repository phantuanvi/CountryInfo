//
//  FrontViewController.swift
//  CountryInfo
//
//  Created by Tuan-Vi Phan on 5/28/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit
import SafariServices
import Alamofire
import SwiftyJSON
import SVProgressHUD

class FrontViewController: UITableViewController {
    
    var arrJSON: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("frontViewController View Did Load")
        if firstTime {
            getDataFromLink()
            firstTime = false
        }
        
        tableView.registerNib(UINib(nibName: "CountryCell", bundle: nil), forCellReuseIdentifier: menus[0])
        
        let leftButtonItem = UIBarButtonItem.init(title: "Menu", style: UIBarButtonItemStyle.Done, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.navigationItem.title = menus[0]
        
       
        
        if (Reachability.isConnectedToNetwork() == false) {
            let alertController = UIAlertController(title: "No Internet Connnection", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(action)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCountrys[0].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = menus[0]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CountryCell
        
        // Configure the cell...
        
        let country = arrCountrys[0][indexPath.row]
        
        cell.configureCell(country)
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let country = arrCountrys[0][indexPath.row]
        let countryName = country.name.replace(" ", replacement: "%20")
        
        
        let link = "https://en.wikipedia.org/wiki/\(countryName)"
        
        //let link = "https://github.com/hjnilsson/country-flags/blob/master/png250px/\(country.alpha2Code).png"
        
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
        
        var arrCountry0 = [Country]()
        var arrCountry1 = [Country]()
        var arrCountry2 = [Country]()
        var arrCountry3 = [Country]()
        var arrCountry4 = [Country]()
        
        for i in 0..<arrJSON.count {
            var dict = arrJSON[i]
            
            let country = Country()
            country.name = dict["name"].stringValue
            country.alpha2Code = dict["alpha2Code"].stringValue.lowercaseString
            country.population = dict["population"].stringValue
            country.area = dict["area"].stringValue
            country.region = dict["region"].stringValue
            
            switch country.region {
            case "Africa":
                arrCountry0.append(country)
            case "Asia":
                arrCountry1.append(country)
            case "Europe":
                arrCountry2.append(country)
            case "Oceania":
                arrCountry3.append(country)
            case "Americas":
                arrCountry4.append(country)
                
            default:
                arrCountry0.append(country)
            }
        }
        
        arrCountrys[0] = arrCountry0
        arrCountrys.append(arrCountry1)
        arrCountrys.append(arrCountry2)
        arrCountrys.append(arrCountry3)
        arrCountrys.append(arrCountry4)
        
        print("parse json done !, arrCountrys: \(arrCountrys.count)")
        
        SVProgressHUD.showSuccessWithStatus("Complete")
        SVProgressHUD.dismissWithDelay(0.5)
        self.tableView.reloadData()
    }    
}

extension String {
    func replace(string: String, replacement: String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}
