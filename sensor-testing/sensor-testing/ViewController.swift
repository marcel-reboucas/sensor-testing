//
//  ViewController.swift
//  sensor-testing
//
//  Created by Marcel de Siqueira Campos Rebouças on 9/3/15.
//  Copyright (c) 2015 mscr. All rights reserved.
//

/*---------------------------------- vejam isso depois
//https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CMAttitude_Class/index.html#//apple_ref/occ/instp/CMAttitude/roll


https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CMDeviceMotion_Class/index.html#//apple_ref/occ/instp/CMDeviceMotion/magneticField


https://github.com/adba/OpenWeatherMapAPI
----------------------------------*/

import UIKit
import CoreMotion
import CoreLocation
import HealthKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var citySegmentedControl: UISegmentedControl!
    
    var sensorDataArray = [(String, String)]()
    var cities = [CityInfo]()
    var selectedCity = 0
    
    // Accelerometer and Gyro
    let motionManager : CMMotionManager = CMMotionManager()

    // Location
    let locationManager : CLLocationManager = CLLocationManager()
    
    // Weather
    let weatherApi : OWMWeatherAPI = OWMWeatherAPI(APIKey: "f34aa439ebd10e124c1d7b663022431b")
    
    // Device
    let device  = UIDevice.currentDevice()
    
    // Healthkit
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Tableview
        tableView.dataSource = self
        tableView.delegate = self
        
        // Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
     
        // Weather
        weatherApi.setTemperatureFormat(kOWMTempCelcius)

        // Proximity
        //device.proximityMonitoringEnabled = true
        
        // HealthKit
        self.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
            }
            else
            {
                println("HealthKit authorization denied!")
                if error != nil {
                    println("\(error)")
                }
            }
        }
        
        cities.append(CityInfo(name: "Recife", coordinate: CLLocationCoordinate2D(latitude: -8.050329, longitude: -34.912695), timezone: NSTimeZone(name: "America/Recife")!))
        cities.append(CityInfo(name: "Floripa", coordinate: CLLocationCoordinate2D(latitude: -27.610951, longitude: -48.517540), timezone: NSTimeZone(name: "America/Sao_Paulo")!))
        cities.append(CityInfo(name: "Tokyo", coordinate: CLLocationCoordinate2D(latitude: 35.694010, longitude: 139.770220), timezone: NSTimeZone(name: "Asia/Tokyo")!))
        
        self.citySegmentedControl.setTitle(cities[0].name, forSegmentAtIndex: 0)
        self.citySegmentedControl.setTitle(cities[1].name, forSegmentAtIndex: 1)
        self.citySegmentedControl.setTitle(cities[2].name, forSegmentAtIndex: 2)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Accelerometer and Gyro
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        
        // Location
        locationManager.startUpdatingLocation()
        
        
        updateSensorDataArray()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Accelerometer and Gyro
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        
        // Location
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func segmentedValueChanged(sender: UISegmentedControl) {
        selectedCity = sender.selectedSegmentIndex
        updateSensorDataArray()
    }
    
    @IBAction func atualizarAction(sender: AnyObject) {
        updateSensorDataArray()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("tableCell") as! UITableViewCell
        
        cell.textLabel?.text = sensorDataArray[indexPath.row].0
        cell.detailTextLabel?.text = sensorDataArray[indexPath.row].1
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensorDataArray.count
    }
    
    func updateSensorDataArray() {
        
        sensorDataArray = [(String, String)]()
        
        sensorDataArray += getLocationData()
        sensorDataArray += getAccelerometerData()
        sensorDataArray += getGyroData()
        getWeatherData()
        getStepCounter()
        
        tableView.reloadData()
    }
    

    
    func getLocationData() -> [(String, String)] {
        
        var locationData = [(String, String)]()
        
        // Check if the user allowed authorization
        if   (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways)
        {
         
            if let location = locationManager.location {
                locationData += [("Latitude", "\(location.coordinate.latitude)")]
                locationData += [("Longitude","\(location.coordinate.longitude)")]
            }
           
            
        }  else {
            locationData += [("Latitude","Not authorized")]
            locationData += [("Longitude","Not authorized")]
        }
        
        return locationData
    }
    
    func getAccelerometerData() -> [(String, String)] {
        
        var accelerometerData = [(String, String)]()
        
        if(motionManager.accelerometerData != nil)
        {
            var data = motionManager.accelerometerData
            
            accelerometerData += [("Accelerometer X", "\(data.acceleration.x)")]
            accelerometerData += [("Accelerometer Y", "\(data.acceleration.y)")]
            accelerometerData += [("Accelerometer Z", "\(data.acceleration.z)")]
        } else {
            accelerometerData += [("Accelerometer X", "Not available")]
            accelerometerData += [("Accelerometer Y", "Not available")]
            accelerometerData += [("Accelerometer Z", "Not available")]
        }
        
        
        return accelerometerData
    }
    
    func getGyroData() -> [(String, String)]
    {
        var gyroData = [(String, String)]()
        
        if(motionManager.gyroData != nil)
        {
            var data = motionManager.gyroData
            
            gyroData += [("Gyro X", "\(data.rotationRate.x)")]
            gyroData += [("Gyro Y", "\(data.rotationRate.y)")]
            gyroData += [("Gyro Z", "\(data.rotationRate.z)")]
        } else {
            gyroData += [("Gyro X", "Not available")]
            gyroData += [("Gyro Y", "Not available")]
            gyroData += [("Gyro Z", "Not available")]
        }
        
        
        return gyroData
    }
    
    func getWeatherData()
    {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = cities[selectedCity].timezone
        
            weatherApi.currentWeatherByCoordinate(cities[selectedCity].coordinate, withCallback: { (error, result) -> Void in
               
                    if result != nil {
                        
                    var weatherData : WeatherInfo = WeatherInfo(data: result)
                
                    self.sensorDataArray += [("Current Temperature", "\(weatherData.temperatureCurrent)")]
                    self.sensorDataArray += [("Weather", "\(weatherData.weather)")]
                    self.sensorDataArray += [("Pressure", "\(weatherData.pressure)")]
                    self.sensorDataArray += [("Humidity", "\(weatherData.humidity)")]
                    self.sensorDataArray += [("Wind speed", "\(weatherData.windSpeed)")]
                    self.sensorDataArray += [("Wind degree", "\(weatherData.windDegree)")]
                    self.sensorDataArray += [("City", "\(weatherData.cityName)")]
                    self.sensorDataArray += [("Country", "\(weatherData.country)")]
                    self.sensorDataArray += [("Sunrise", "\(dateFormatter.stringFromDate(weatherData.sunrise))")]
                    self.sensorDataArray += [("Sunset", "\(dateFormatter.stringFromDate(weatherData.sunset))")]

                    let cityHour = NSDate()
                    self.sensorDataArray += [("Time", dateFormatter.stringFromDate(cityHour))]
                    
                        //if cityhour is later than sunrise and before sunset, then it's day
                        if cityHour.compare(weatherData.sunrise) == NSComparisonResult.OrderedDescending &&
                        cityHour.compare(weatherData.sunset) == NSComparisonResult.OrderedAscending {
                            self.sensorDataArray += [("Day/Night", "Day")]
                        } else {
                            self.sensorDataArray += [("Day/Night", "Night")]
                        }
                    
                    self.tableView.reloadData()
            }
        })
    }
    
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = Set([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            ])
        
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite = Set([
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
            ])
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "br.ufpe.mscr", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    
    func getStepCounter(){
    
        
        let calendar = NSCalendar.currentCalendar()
        
        let endDate = NSDate()
        let startOfToday = calendar.startOfDayForDate(endDate)

        
        let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let predicate = HKQuery.predicateForSamplesWithStartDate(startOfToday, endDate: endDate, options: .None)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
            (query, results, error) in
            if results == nil {
                println("There was an error running the query: \(error)")
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                var stepsToday:Double = 0
                
                for steps in results as! [HKQuantitySample]
                {
                    // add values to dailyAVG
                    stepsToday += steps.quantity.doubleValueForUnit(HKUnit.countUnit())
                }
            
                self.sensorDataArray += [("Steps today", "\(stepsToday)")]
            }
        })
        
        if healthKitStore.authorizationStatusForType(HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)) == HKAuthorizationStatus.SharingAuthorized {
        
            healthKitStore.executeQuery(query)
        }
    }
}

