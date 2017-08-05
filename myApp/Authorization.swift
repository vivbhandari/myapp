//
//  Authorization.swift
//  myApp
//
//  Created by vivek bhandari on 8/5/17.
//  Copyright © 2017 vivek bhandari. All rights reserved.
//

import UIKit

class Authorization {
    
    //MARK: Variables
    var username: String
    var password: String
    var access_token: String = ""
    var refresh_token: String = ""
    var token_type: String = ""
    var expires_in: Int = -1
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

