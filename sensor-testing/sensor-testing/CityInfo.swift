//
//  CityInfo.swift
//  sensor-testing
//
//  Created by Marcel de Siqueira Campos Rebouças on 9/8/15.
//  Copyright (c) 2015 mscr. All rights reserved.
//

import Foundation

class CityInfo {
    var name : String
    var coordinate : CLLocationCoordinate2D
    var timezone : NSTimeZone
    
    init (name : String, coordinate : CLLocationCoordinate2D, timezone : NSTimeZone) {
        self.name = name
        self.coordinate = coordinate
        self.timezone = timezone
    }

}