//
//  ViewController.swift
//  sensor-testing
//
//  Created by Marcel de Siqueira Campos Rebouças on 9/3/15.
//  Copyright (c) 2015 mscr. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var sensorDataArray = [(String, String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        updateSensorDataArray()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        tableView.reloadData()
        
    }
    
    func getLocationData() -> [(String, String)] {
    
        return [("location1", "data1"), ("location2", "data2")]
    }
    
    func getAccelerometerData() -> [(String, String)] {
        
        return [("accelometer1", "data1")]
    }
}

