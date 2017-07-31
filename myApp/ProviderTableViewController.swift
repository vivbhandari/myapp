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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getProviders()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    private func getProviders() {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "http://localhost/myapp/myresource/providers")!
        let task = session.dataTask(with: url, completionHandler: {
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
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        super.prepare(for: segue, sender: sender)
        let destinationNavigationController = segue.destination as! UINavigationController
        let providerMapViewController = destinationNavigationController.topViewController as? ProviderMapViewController
        providerMapViewController?.providers = self.providers
    }
}
