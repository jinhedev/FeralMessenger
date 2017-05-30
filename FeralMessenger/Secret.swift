//
//  Time.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/27/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Foundation


class Secret: NSObject {
    
    static let almostMidNight: Int = 23
    
    static let shared = Secret()
    
    func setupSecret() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: date)
        if let hourInt = Int(hourString) {
            if hourInt > Secret.almostMidNight {
                addButton()
            }
        }
    }
    
    private func addButton() {
        print("It's the secret hour")
    }

}















