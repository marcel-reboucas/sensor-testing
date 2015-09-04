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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var sensorDataArray = [(String, String)]()
    
    var motion:CMMotionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        motion.startAccelerometerUpdates()
        motion.startGyroUpdates()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        updateSensorDataArray()
    }
    
    @IBAction func atualizarAction(sender: AnyObject) {
        self.updateSensorDataArray()
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
    
    func getGyroData() -> [(String, String)]
    {//eu vou abrir a cahve em baixo e que se dane o mundo, vems
        var ret = [("", ""),("", ""),("", "")]
        
        if(motion.gyroData != nil)
        {
            var data = motion.gyroData
            
            ret[0].0 = "gyro x"
            ret[0].1 = "\(data.rotationRate.x)"
           
            ret[1].0 = "gyro y"
            ret[1].1 = "\(data.rotationRate.y)"
            
            ret[2].0 = "gyro z"
            ret[2].1 = "\(data.rotationRate.z)"
            
        }
        
        
        return ret
    }
    
    func getLocationData() -> [(String, String)] {
        
        return [("location1", "data1"), ("location2", "data2")]
    }
    
    func getAccelerometerData() -> [(String, String)] {
        
        var ret = [("", ""),("", ""),("", "")]
        
        if(motion.accelerometerData != nil)
        {
            var data = motion.accelerometerData
            
            ret[0].0 = "accelerometer x"
            ret[0].1 = "\(data.acceleration.x)"
            
            ret[1].0 = "accelerometer y"
            ret[1].1 = "\(data.acceleration.y)"
            
            ret[2].0 = "accelerometer z"
            ret[2].1 = "\(data.acceleration.z)"
        }
        
        
        return ret
    }
}

