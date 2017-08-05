//
//  Helper.swift
//  myApp
//
//  Created by vivek bhandari on 8/5/17.
//  Copyright © 2017 vivek bhandari. All rights reserved.
//


import UIKit

class Helper {
    static func showAlert(message: String, parentController: UIViewController) {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            parentController.present(alert, animated: true, completion: nil)
        }
    }
}
