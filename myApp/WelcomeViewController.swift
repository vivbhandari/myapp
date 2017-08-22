//
//  ViewController.swift
//  myApp
//
//  Created by vivek bhandari on 7/24/17.
//  Copyright © 2017 vivek bhandari. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    //MARK: Variables
    var authorization: Authorization? = nil

    //MARK: Properties
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    //MARK: Actions
    @IBAction func signIn(_ sender: UIButton) {
        guard let username = self.usernameText!.text else {
            Helper.showAlert(message: "Enter username", parentController: self)
            return
        }
        guard let password = self.passwordText!.text else {
            Helper.showAlert(message: "Enter password", parentController: self)
            return
        }
        self.authorization = Authorization(username: username, password: password)
        self.loadAuthenticationToken(function: self.navigateToNextView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field’s user input through delegate callbacks.
        usernameText.delegate = self
        passwordText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }

    private func navigateToNextView() {
        OperationQueue.main.addOperation {
            let providerTableNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProviderTableNavigationController") as! UINavigationController
            let providerTableViewController = providerTableNavigationController.topViewController as? ProviderTableViewController
            providerTableViewController?.authorization = self.authorization
            self.present(providerTableNavigationController, animated: true, completion: nil)
        }
    }

    private func loadAuthenticationToken(function:@escaping ()->Void) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let urlFormat = "http://localhost/myapp/user/authentication?username=%@&password=%@"
        let username = self.authorization!.username.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let password = self.authorization!.password.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url = URL(string: String(format: urlFormat, username, password) )!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    print("statusCode=" + String(httpResponse.statusCode))
                    if(httpResponse.statusCode == 201) {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                        {
                            print(json)
                            self.authorization!.access_token = json["access_token"]! as! String
                            self.authorization!.refresh_token = json["refresh_token"]! as! String
                            self.authorization!.token_type = json["token_type"]! as! String
                            self.authorization!.expires_in = json["expires_in"]! as! Int
                            function()
                        }} else{
                        Helper.showAlert(message: "Authentication failed", parentController: self)
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
}
