//
//  ProviderTableViewController.swift
//  myApp
//
//  Created by vivek bhandari on 7/29/17.
//  Copyright © 2017 vivek bhandari. All rights reserved.
//

import UIKit

class ProviderTableViewController: UITableViewController {

    //MARK: Properties
    @IBOutlet weak var refreshButton: UIBarButtonItem!

    //MARK: Actions
    @IBAction func refreshAction(_ sender: UIBarButtonItem) {
        self.getProviders(token: token)
    }
    
    //MARK: Variables
    var providers = [Provider]()
    var username = "user1"
    var password = "password1"
    var token: String = ""
    var refreshToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAuthenticationToken(function: self.getProviders)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return providers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ProviderTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProviderTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ProviderTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let provider = providers[indexPath.row]
        
        // Configure the cell...
        cell.title.text = provider.title
        cell.address.text = provider.address
        cell.photo.image = provider.photo
        
        return cell
    }
    
    private func loadAuthenticationToken(function:@escaping (String)->Void) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let urlFormat = "http://localhost/myapp/authentication?username=%@&password=%@"
        let url = URL(string: String(format: urlFormat, self.username, self.password) )!
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
                            self.token = json["access_token"]! as! String
                            self.refreshToken = json["refresh_token"]! as! String
                            function(self.token)
                        }} else{
                        self.showAlert(message: "Authentication failed")
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }

    private func refreshAuthenticationToken(function:@escaping (String)->Void) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let urlFormat = "http://localhost/myapp/authentication/refresh?username=%@&token=%@"
        let url = URL(string: String(format: urlFormat, self.username, self.refreshToken) )!
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
                            self.token = json["access_token"]! as! String
                            self.refreshToken = json["refresh_token"]! as! String
                            function(self.token)
                        }} else{
                        self.showAlert(message: "Authentication failed")
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }

    private func getProviders(token :String) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "http://localhost/myapp/myresource/providers")!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    print("statusCode=" + String(httpResponse.statusCode))
                    if(httpResponse.statusCode == 200) {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                        {
                            print(json)
                            self.providers.removeAll()
                            let jsonProviders = json["providers"] as? [[String: String]]
                            for jsonProvider in jsonProviders!{
                                let jsonProviderData = jsonProvider as [String: String]
                                self.providers += [Provider(title: jsonProviderData["title"]!, address: jsonProviderData["address"]!)]
                            }
                            self.tableView.reloadData()
                        }
                    }
                    else if(httpResponse.statusCode == 401) {
                        print("Authentication failed. Refresh token.")
                        self.refreshAuthenticationToken(function: self.getProviders)
                    }
                    else {
                        self.showAlert(message: "Server error")
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        super.prepare(for: segue, sender: sender)
        let destinationNavigationController = segue.destination as! UINavigationController
        let providerMapViewController = destinationNavigationController.topViewController as? ProviderMapViewController
        providerMapViewController?.providers = self.providers
    }
}
