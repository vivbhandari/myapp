//
//  Provider.swift
//  myApp
//
//  Created by vivek bhandari on 7/29/17.
//  Copyright © 2017 vivek bhandari. All rights reserved.
//

import UIKit

class Provider {
    
    //MARK: Properties
    var title: String
    var address: String
    var photo: UIImage?
    var lat: Double
    var long: Double
    var hasCoordinates: Bool
    
    //MARK: Intitializers
    convenience init(title: String, address: String){
        self.init(title: title, address: address, photo: nil)
    }

    init(title: String, address: String, photo: UIImage?){
        self.title = title
        self.address = address
        self.photo = photo
        self.lat = 0
        self.long = 0
        self.hasCoordinates = false
    }
}
