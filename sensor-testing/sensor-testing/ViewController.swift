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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Tableview
        tableView.dataSource = self
        tableView.delegate = self
        
        // Location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
     

 
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
        }
        
        
        return gyroData
    }
}

