//
//  RegisterViewController.swift
//  myApp
//
//  Created by vivek bhandari on 7/24/17.
//  Copyright © 2017 vivek bhandari. All rights reserved.
//

import UIKit
import Stripe

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var photo: UIImageView!
    var imagePicker: UIImagePickerController!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Variables
    var authorization: Authorization? = nil
    let defaultImage = UIImage(named: "default")
    var tokenId: String? = nil

    //MARK: Actions
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func submit(_ sender: UIButton) {
        self.getStripeTokenAndProcessSubmit()
    }

    func processSubmit(){
        var input: Dictionary<String, String> =  [String : String]()
        self.authorization = Authorization(username: self.emailId!.text!, password: self.password!.text!)
        input["name"] = self.name!.text!
        input["address"] = self.address!.text!
        input["emailId"] = self.emailId!.text!
        input["password"] = self.password!.text!
        if self.photo.image != defaultImage {
            let imageData = UIImagePNGRepresentation(self.photo.image!)
            input["image"] = imageData!.base64EncodedString()
        }
        input["tokenId"] = self.tokenId!
        self.register(dict: input, function: self.navigateToNextView)
    }

    @IBAction func launchCamera(_ sender: UIButton) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            let alertController = UIAlertController.init(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
    }

    @IBAction func launchPhotoLibrary(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        // Set photoImageView to display the selected image.
        self.photo.image = selectedImage
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }

    //MARK: Private methods
    private func register(dict: Dictionary<String, String>, function:@escaping ()->Void) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: String(format:"http://localhost:%@/myapp/user/register", MyVariables.port))!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            print(jsonData)
            urlRequest.httpBody = jsonData
        }
        catch {
            print("error in JSONSerialization")
        }

        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                do {
                    let httpResponse = response as! HTTPURLResponse
                    print("statusCode=" + String(httpResponse.statusCode))
                    let errorCodes = [409, 417]
                    if(httpResponse.statusCode == 201) {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                        {
                            print(json)
                            self.authorization!.access_token = json["access_token"]! as! String
                            self.authorization!.refresh_token = json["refresh_token"]! as! String
                            self.authorization!.token_type = json["token_type"]! as! String
                            self.authorization!.expires_in = json["expires_in"]! as! Int
                            function()
                        }
                    }
                    else if(errorCodes.contains(httpResponse.statusCode)) {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                        {
                            print(json)
                            let reason = json["reason"]! as! String
                            Helper.showAlert(message: reason, parentController: self)
                        }
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

    private func navigateToNextView() {
        OperationQueue.main.addOperation {
            let providerTableNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProviderTableNavigationController") as! UINavigationController
            let providerTableViewController = providerTableNavigationController.topViewController as? ProviderTableViewController
            providerTableViewController?.authorization = self.authorization
            self.present(providerTableNavigationController, animated: true, completion: nil)
        }
    }


    func getStripeTokenAndProcessSubmit() {
        print("getStripeTokenAndProcessSubmit")
        let stripCard = STPCard()
        stripCard.number = "4242424242424242"
        stripCard.cvc = "222"
        stripCard.expMonth = 7
        stripCard.expYear = 2019

        do{
            try stripCard.validateReturningError()
        } catch let error {
            print(error)
        }

        STPAPIClient.shared().createToken(with: stripCard, completion: { (token, error) -> Void in

            if error != nil {
                print(error!)
            }
            self.tokenId = token!.tokenId
            print("tokenId=" + String(describing: self.tokenId))
            self.processSubmit()
        })
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
