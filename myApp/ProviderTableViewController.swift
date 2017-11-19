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
        self.getProviders()
    }

    //MARK: Variables
    var providers = [Provider]()
    var authorization: Authorization? = nil
    let defaultImage = UIImage(named: "default")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.getProviders()

        let button = UIButton.init(type: .custom)

        //set image for button
        var userImage = UIImage(named: "crosshairs")
        if self.authorization?.image != nil {
            userImage = self.authorization?.image
        }
        button.setImage(userImage, for: UIControlState.normal)

        //add function for button
        //        button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(button:)), for: .touchUpInside)
        //        button.addTarget(self, action: "fbButtonPressed", for: UIControlEvents.TouchUpInside)

        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30) //CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem.init(customView: button)
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
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

    private func refreshAuthenticationToken(function:@escaping ()->Void) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let urlFormat = "http://localhost:%@/myapp/user/authentication/refresh?username=%@&token=%@"
        let url = URL(string: String(format: urlFormat, MyVariables.port, self.authorization!.username, self.authorization!.refresh_token) )!
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
                            if(json["image"] != nil){
                                let decodedData = Data(base64Encoded: json["image"]! as! String , options: .ignoreUnknownCharacters)
                                self.authorization!.image = UIImage(data: decodedData!)
                            }
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

    private func getProviders() {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: String(format: "http://localhost:%@/myapp/myresource/providers", MyVariables.port))!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer " + self.authorization!.access_token, forHTTPHeaderField: "Authorization")
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
                            var count = 0
                            let jsonProviders = json["providers"] as? [[String: String]]
                            for jsonProvider in jsonProviders!{
                                let jsonProviderData = jsonProvider as [String: String]
                                var image = self.defaultImage
                                if(jsonProviderData["image"] != nil){
                                    let decodedData = Data(base64Encoded: jsonProviderData["image"]!, options: .ignoreUnknownCharacters)
                                    image = UIImage(data: decodedData!)
                                }
                                self.providers += [Provider(title: jsonProviderData["title"]!, address: jsonProviderData["address"]!, photo: image)]
                                count += 1
                            }
                            print("total count=" + String(count))
                            self.tableView.reloadData()
                        }
                    }
                    else if(httpResponse.statusCode == 401) {
                        print("Authentication failed. Refresh token.")
                        self.refreshAuthenticationToken(function: self.getProviders)
                    }
                    else {
                        Helper.showAlert(message: "Server error", parentController: self)
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
        providerMapViewController?.authorization = self.authorization
    }
}
