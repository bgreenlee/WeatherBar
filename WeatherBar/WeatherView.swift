//
//  WeatherView.swift
//  WeatherBar
//
//  Created by Brad Greenlee on 10/13/15.
//  Copyright © 2015 Etsy. All rights reserved.
//

import Cocoa

class WeatherView: NSView {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var cityTextField: NSTextField!
    @IBOutlet weak var currentConditionsTextField: NSTextField!
    
    func update(weather: Weather) {
        // do UI updates on the main thread
        dispatch_async(dispatch_get_main_queue()) {
            self.cityTextField.stringValue = weather.city
            self.currentConditionsTextField.stringValue = "\(Int(weather.currentTemp))°F and \(weather.conditions)"
            self.imageView.image = NSImage(named: weather.icon)
        }
    }
}
