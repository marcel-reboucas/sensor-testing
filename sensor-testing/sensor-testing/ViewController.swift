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
----------------------------------*/

import UIKit
import CoreMotion
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sensorDataArray = [(String, String)]()
    
    // Accelerometer and Gyro
    var motionManager : CMMotionManager = CMMotionManager()

    // Location
    var locationManager : CLLocationManager = CLLocationManager()
    
    // Weather
    var weatherApi : OWMWeatherAPI = OWMWeatherAPI(APIKey: "f34aa439ebd10e124c1d7b663022431b")
  
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

 
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Accelerometer and Gyro
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        
        // Magnetometer
        motionManager.startMagnetometerUpdates()
        
        // Location
        locationManager.startUpdatingLocation()
        
        
        updateSensorDataArray()
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Accelerometer and Gyro
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        
        // Magnetometer
        motionManager.stopMagnetometerUpdates()
        
        // Location
        locationManager.stopUpdatingLocation()
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
        sensorDataArray += getMagnetometerData()
       
        getTemperatureData()
        
        tableView.reloadData()
        
    }
    
    func getMagnetometerData() -> [(String, String)]{
        var magnetometerData = [(String , String)]()
        
        if(motionManager.magnetometerData != nil)
        {
            var data = motionManager.magnetometerData
            
            magnetometerData += [("MagnetctField x" , "\(data.magneticField.x)")]
            magnetometerData += [("MagnetctField y" , "\(data.magneticField.y)")]
            magnetometerData += [("MagnetctField z" , "\(data.magneticField.z)")]
        } else {
            magnetometerData += [("MagnetctField x" , "Not authorized")]
            magnetometerData += [("MagnetctField y" , "Not authorized")]
        }
        
        return magnetometerData
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
    
    func getTemperatureData()
    {
        var temperatureData = [(String, String)]()
        
        if   (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways)
        {
            weatherApi.currentWeatherByCoordinate(locationManager.location.coordinate, withCallback: { (error, result) -> Void in
               
                var weatherData : WeatherInfo = WeatherInfo(data: result)
                
                self.sensorDataArray += [("Current Temperature", "\(weatherData.temperatureCurrent)")]
                self.sensorDataArray += [("Max Temperature", "\(weatherData.temperatureMax)")]
                self.sensorDataArray += [("Min Temperature", "\(weatherData.temperatureMin)")]
                self.sensorDataArray += [("Weather", "\(weatherData.weather)")]
                self.sensorDataArray += [("Pressure", "\(weatherData.pressure)")]
                self.sensorDataArray += [("Humidity", "\(weatherData.humidity)")]
                self.sensorDataArray += [("Wind speed", "\(weatherData.windSpeed)")]
                self.sensorDataArray += [("Wind degree", "\(weatherData.windDegree)")]
                self.sensorDataArray += [("City", "\(weatherData.cityName)")]
                self.sensorDataArray += [("Country", "\(weatherData.country)")]
                self.sensorDataArray += [("Sea Level", "\(weatherData.seaLevel)")]
                
                self.tableView.reloadData()
            })
        }
    }
}

