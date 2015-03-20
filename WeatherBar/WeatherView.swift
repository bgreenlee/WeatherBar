//
//  WeatherView.swift
//  WeatherBar
//
//  Created by Brad Greenlee on 3/19/15.
//  Copyright (c) 2015 Etsy. All rights reserved.
//

import Cocoa

class WeatherView: NSView {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var cityTextField: NSTextField!
    @IBOutlet weak var currentConditionsTextField: NSTextField!
    
    func update(weather: Weather) {
        cityTextField.stringValue = weather.city
        currentConditionsTextField.stringValue = "\(Int(weather.currentTemp))°F and \(weather.conditions)"
    }
}