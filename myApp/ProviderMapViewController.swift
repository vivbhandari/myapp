//
//  ProviderViewController.swift
//  myApp
//
//  Created by vivek bhandari on 7/25/17.
//  Copyright © 2017 vivek bhandari. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ProviderMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let defaultImage = UIImage(named: "default")
    let googleKey = "AIzaSyBG149OzbaQ-PNxy4pXxqQHamRrm1s5jw0"
    var providers = [Provider]()
    
    //MARK: Annotations
    class MyLocation: NSObject,MKAnnotation{
        var identifier = "my location"
        var title: String?
        var coordinate: CLLocationCoordinate2D
        var providerImage: UIImage?
        init(name:String,lat:CLLocationDegrees,long:CLLocationDegrees, image: UIImage){
            title = name
            coordinate = CLLocationCoordinate2DMake(lat, long)
            providerImage = image
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view : MKAnnotationView
        guard let annotation = annotation as? MyLocation else {return nil}
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) as? MKPinAnnotationView {
            dequeuedView.pinTintColor = UIColor.magenta
            view = dequeuedView
        }else { //make a new view
            if annotation.providerImage != defaultImage{
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                let imageView = UIImageView(image: annotation.providerImage)
                var r: CGRect = imageView.frame
                r.size.height = 30
                r.size.width = 30
                imageView.frame = r;
                view.addSubview(imageView)
            } else{
                let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                pinView.pinTintColor = UIColor.magenta
                view = pinView
            }
        }
        view.isEnabled = true
        view.canShowCallout = true
        return view
    }
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Actions
    @IBAction func listView(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        getGoogleCoordinates(providers: providers)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate
        userLocation: MKUserLocation) {
        mapView.centerCoordinate = userLocation.location!.coordinate
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.location!.coordinate, 3000, 3000)
        mapView.setRegion(region, animated: true)
    }
    
    private func getGoogleCoordinates(providers: [Provider]) {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        for provider: Provider in self.providers {
            if (!provider.hasCoordinates) {
                let restAddress = provider.address.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?address="+restAddress+"&key="+self.googleKey)!
                let task = session.dataTask(with: url, completionHandler: {
                    (data, response, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                    } else {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                            {
                                print(json)
                                let results = json["results"] as? [[String: Any]]
                                let result = results![0] as [String: Any]
                                let geometry = result["geometry"] as? [String: Any]
                                let location = geometry!["location"] as? [String: Any]
                                let lat = location!["lat"] as! Double
                                let long = location!["lng"] as! Double
                                provider.lat = lat
                                provider.long = long
                                provider.hasCoordinates = true
                                self.mapView.addAnnotation(MyLocation(name:provider.title,lat:provider.lat, long:provider.long, image: provider.photo!))
                            }
                        } catch {
                            print("error in JSONSerialization")
                        }
                    }
                })
                task.resume()
            } else {
                self.mapView.addAnnotation(MyLocation(name:provider.title,lat:provider.lat,long:provider.long, image: provider.photo!))
            }
        }
    }
}
