//
//  ViewController.swift
//  Assignment2
//
//  Created by Drashti Akbari on 2020-04-01.
//  Copyright © 2020 Drashti Akbari. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import SwiftGifOrigin
import ActionSheetPicker_3_0

class ViewController: UIViewController {
    
    var arrOfWeatherData = NSArray()
    var locationManager = CLLocationManager()
    var listOfWeather = NSArray()
    var arrOfCity = NSDictionary()
    var arrOfDaysName = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var arrOfDays = NSMutableArray()
    var arrOfFilter = NSMutableArray()
    var arrOfNoonData = NSMutableArray()
    var selection : Int = 0
    var filter = ""
    var baseApi = "http://api.openweathermap.org/data/2.5/forecast?"
    var unit = "metric"
    var appId = "9910f3c254eb28526bca77bf93731e86"
    var hour = "12:00"
    
    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var gifLoad : UIImageView!
    @IBOutlet weak var lblCityName : UILabel!
    @IBOutlet weak var lblFilter : UILabel!
    @IBOutlet weak var lblNoData : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblNoData.isHidden = true
        gifLoad.loadGif(name: "background")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        getWeatherDataApi()
    }
    
    func getDate(stringDate: String) -> String
    {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let showDate = inputFormatter.date(from: stringDate)
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    
    func getDayName(stringDate: String) -> String
    {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let showDate = inputFormatter.date(from: stringDate)
        inputFormatter.dateFormat = "EEEE"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    
    func getHour(stringDate: String) -> String
    {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let showDate = inputFormatter.date(from: stringDate)
        inputFormatter.dateFormat = "HH:mm"
        let resultString = inputFormatter.string(from: showDate!)
        return resultString
    }
    
    func getWeatherDataApi() {
        
        let coordinate: CLLocationCoordinate2D = getLocation()
        let latitude = "\(coordinate.latitude)"
        let longitude = "\(coordinate.longitude)"
        let url = "\(baseApi)lat=\(latitude)&lon=\(longitude)&units=\(unit)&appid=\(appId)"
        
        Alamofire.request(url).responseJSON { (responseData) -> Void in
            if((responseData.result.value) != nil) {
                let swiftyJsonVar = JSON(responseData.result.value!)
                if let responseCityData = swiftyJsonVar["city"].dictionary {
                    self.arrOfCity = responseCityData as NSDictionary
                }
                if let responseListData = swiftyJsonVar["list"].arrayObject  {
                    self.arrOfWeatherData = responseListData as NSArray
                }
                if self.arrOfWeatherData.count > 0 {
                    let city = "\(String(describing: self.arrOfCity.value(forKey: "name") ?? ""))"
                    for index in 0..<self.arrOfWeatherData.count
                    {
                        let dateForTableView = ((self.arrOfWeatherData.object(at: index) as! NSDictionary).value(forKey: "dt_txt") as?  String)!
                        let dateForCollectionView = ((self.arrOfWeatherData.object(at: 0) as! NSDictionary).value(forKey: "dt_txt") as?  String)!
                        
                        if self.hour == self.getHour(stringDate: dateForTableView)
                        {
                            let hourDictionary = self.arrOfWeatherData.object(at: index) as! NSDictionary
                            self.arrOfDays.add(hourDictionary)
                            self.tableView.reloadData()
                        }
                        if self.getDate(stringDate: dateForCollectionView) == self.getDate(stringDate: dateForTableView) {
                            let hourDictionaryByDay = self.arrOfWeatherData.object(at: index) as! NSDictionary
                            self.arrOfNoonData.add(hourDictionaryByDay)
                            self.lblFilter.text = self.getDayName(stringDate: dateForCollectionView)
                            self.collectionView.reloadData()
                        }
                    }
                    self.lblCityName.text = city
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func btn_Filter_Action(_ sender: Any) {
     
        self.arrOfFilter = []
        self.filter = "filter"
        
        ActionSheetStringPicker.show(withTitle: "Select Day by Name", rows: arrOfDaysName , initialSelection: selection, doneBlock: { (picker, selectedIndex, origin) in
            
            self.selection = selectedIndex
            let selectedDay = self.arrOfDaysName[selectedIndex]
            self.lblFilter.text = selectedDay
            
            for index in 0..<self.arrOfWeatherData.count
            {

                let weatherDateTime = ((self.arrOfWeatherData.object(at: index) as! NSDictionary).value(forKey: "dt_txt") as?  String)!
                
                if selectedDay == self.getDayName(stringDate: weatherDateTime)
                {
                    self.filter = "filter"
                    let dayNameDictionary = self.arrOfWeatherData.object(at: index) as! NSDictionary

                    self.arrOfFilter.add(dayNameDictionary)
                    self.collectionView.reloadData()
                }
                
            }
            self.collectionView.reloadData()
        }, cancel: { (picker) in
            
        }, origin: self.view)
    }
}

extension ViewController : CLLocationManagerDelegate{
    
    func getLocation() -> CLLocationCoordinate2D {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        let location: CLLocation? = locationManager.location
        let coordinate: CLLocationCoordinate2D? = location?.coordinate
        if let aCoordinate = coordinate {
            return aCoordinate
        }
        return CLLocationCoordinate2D()
    }
}

class Weather : UITableViewCell {
    @IBOutlet weak var imgViewWeather : UIImageView!
    @IBOutlet weak var lblDay : UILabel!
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblDiscription : UILabel!
    @IBOutlet weak var lblTemperature : UILabel!
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfDays.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellWeather", for: indexPath as IndexPath) as! Weather
        let weather = (self.arrOfDays.object(at: indexPath.row) as! NSDictionary).value(forKey: "weather") as! NSArray
        let main =  (self.arrOfDays.object(at: indexPath.row) as! NSDictionary).value(forKey: "main") as! NSDictionary
        let weatherDate = ((self.arrOfDays.object(at: indexPath.row) as! NSDictionary).value(forKey: "dt_txt") as?  String)!
        let icon = ((weather.object(at: 0) as! NSDictionary).value(forKey: "icon") as?  String)!

        cell.lblDiscription.text = ((weather.object(at: 0) as! NSDictionary).value(forKey: "main") as?  String)!
        cell.lblTemperature.text = "\(String(Int(main.value(forKey: "temp") as! Double)))"
        cell.lblDay.text = getDayName(stringDate: weatherDate)
        cell.lblDuration.text = "\(getHour(stringDate: weatherDate)) PM"
        cell.imgViewWeather.image = UIImage(named: "\(icon)")
        
        return cell
    }
    
}

class HourlyWeather : UICollectionViewCell {
    
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblTemperature : UILabel!
    @IBOutlet weak var imgWeather : UIImageView!
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if filter == "filter" {
            if arrOfFilter.count > 0 {
                lblNoData.isHidden = true
                tableView.backgroundView = nil
                return arrOfFilter.count
            }
            else {
                lblNoData.isHidden = false
            }
        }
        else {
            lblNoData.isHidden = true
            return arrOfNoonData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellHourlyWeather", for: indexPath as IndexPath) as! HourlyWeather
        
        if filter == "filter" {
            let main =  (self.arrOfFilter.object(at: indexPath.row) as! NSDictionary).value(forKey: "main") as! NSDictionary
            let weather = (self.arrOfFilter.object(at: indexPath.row) as! NSDictionary).value(forKey: "weather") as! NSArray
            let icon = ((weather.object(at: 0) as! NSDictionary).value(forKey: "icon") as?  String)!
            let date = ((self.arrOfFilter.object(at: indexPath.row) as! NSDictionary).value(forKey: "dt_txt") as?  String)!

            cell.lblTemperature.text = "\(String(Int(main.value(forKey: "temp") as! Double))) °C"
            cell.lblDuration.text = getHour(stringDate: date)
            cell.imgWeather.image = UIImage(named: "\(icon)")
        }
        else {
            
            let main =  (self.arrOfNoonData.object(at: indexPath.row) as! NSDictionary).value(forKey: "main") as! NSDictionary
            let weather = (self.arrOfNoonData.object(at: indexPath.row) as! NSDictionary).value(forKey: "weather") as! NSArray
            let icon = ((weather.object(at: 0) as! NSDictionary).value(forKey: "icon") as?  String)!
            let date = ((self.arrOfNoonData.object(at: indexPath.row) as! NSDictionary).value(forKey: "dt_txt") as?  String)!

            cell.lblTemperature.text = "\(String(Int(main.value(forKey: "temp") as! Double))) °C"
            cell.lblDuration.text = getHour(stringDate: date)
            cell.imgWeather.image = UIImage(named: "\(icon)")
        }
        return cell
    }
}


