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

    static func post(url: String, handler:@escaping ()->Void) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        var urlRequest = URLRequest(url: URL(string: url )!)
        urlRequest.httpMethod = "POST"
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                handler()
            }
        })
        task.resume()
    }

    static func get(url: String, authorization: Authorization, handler:@escaping ()->Void) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        var urlRequest = URLRequest(url: URL(url)!)
        urlRequest.addValue("Bearer " + authorization!.access_token, forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                handler()
            }
        })
        task.resume()
    }
}
