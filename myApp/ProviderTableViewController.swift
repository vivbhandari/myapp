//
//  ProviderTableViewController.swift
//  myApp
//
//  Created by vivek bhandari on 7/29/17.
//  Copyright © 2017 vivek bhandari. All rights reserved.
//

import UIKit

class ProviderTableViewController: UITableViewController {
    
    //MARK: Variables
    var providers = [Provider]()
    var username = "user1"
    var password = "password1"
    var token: String = ""
    
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
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: String]
                    {
                        print(json)
                        self.token = json["token"]!
                        function(self.token)
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
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                    {
                        print(json)
                        let jsonProviders = json["providers"] as? [[String: String]]
                        for jsonProvider in jsonProviders!{
                            let jsonProviderData = jsonProvider as [String: String]
                            self.providers += [Provider(title: jsonProviderData["title"]!, address: jsonProviderData["address"]!)]
                        }
                        self.tableView.reloadData()
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
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
