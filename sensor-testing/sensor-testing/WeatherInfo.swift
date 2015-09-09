//
//  WeatherInfo.swift
//  sensor-testing
//
//  Created by Marcel de Siqueira Campos Rebouças on 9/4/15.
//  Copyright (c) 2015 mscr. All rights reserved.
//

import UIKit

public class WeatherInfo {
   
    var cityName : String
    var country : String
    var sunrise : NSDate
    var sunset : NSDate
    var weather : String
    var temperatureCurrent : Double
    var temperatureMin : Double
    var temperatureMax : Double
    var pressure : Double
    var humidity : Double
    var windSpeed : Double
    
    init (data : NSDictionary) {
    
        cityName = data["name"] as! String
        
        var sys = data["sys"] as! NSDictionary
        country = sys.valueForKey("country") as! String
        sunrise = sys.valueForKey("sunrise") as! NSDate
        sunset =  sys.valueForKey("sunset") as! NSDate
        
        var wea = (data["weather"] as! NSArray).objectAtIndex(0) as! NSDictionary
        weather = wea["main"] as! String
        
        var main = data["main"] as! NSDictionary
        temperatureCurrent = main["temp"] as! Double
        temperatureMin = main["temp_min"] as! Double
        temperatureMax = main["temp_max"] as! Double
        pressure = main["pressure"] as! Double
        humidity = main["humidity"] as! Double
        
        var wind = data["wind"] as! NSDictionary
        windSpeed = wind["speed"] as! Double
    
    }
}
