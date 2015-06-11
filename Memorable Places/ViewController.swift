//
//  ViewController.swift
//  Memorable Places
//
//  Created by Daniel Ryan on 5/25/15.
//  Copyright (c) 2015 Daniel Ryan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    var locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        if activePlace == -1
        {
            // center over current location
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        else
        {
            // center over active location
            var lat:CLLocationDegrees = NSString(string: places[activePlace]["lat"]!).doubleValue
            var long:CLLocationDegrees = NSString(string: places[activePlace]["long"]!).doubleValue
            
            moveMap(lat, long: long)
        }
        
        
        // add annotations
        
        for place in places
        {
            var lat: CLLocationDegrees = NSString(string: place["lat"]!).doubleValue
            var long: CLLocationDegrees = NSString(string: place["long"]!).doubleValue
            var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
            
            var annotation: MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = place["title"]
            
            
            self.map.addAnnotation(annotation)
            
        }

        
        var uilpgr =   UILongPressGestureRecognizer(target: self, action: "action:")

        map.addGestureRecognizer(uilpgr)
        
    }
    
    func action(gestureRecognizer: UIGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizerState.Began
        {
            
            var annotation = MKPointAnnotation()
            
            var touchPoint = gestureRecognizer.locationInView(self.map)
            
            var coordinate:CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            annotation.coordinate = coordinate
            
            // display the address closest annotation
            
            var location:CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            

            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
                (placemarks, error) -> Void in
                

                var title = ""
                
                if error == nil
                {
                    
                    if let pm = CLPlacemark(placemark: placemarks?[0] as! CLPlacemark)
                    {
                        
                        var subThoroughfare:String = ""
                        var thoroughfare:String = ""
                        
                        if (pm.subThoroughfare != nil)
                        {
                            subThoroughfare = pm.subThoroughfare
                        }
                        
                        if (pm.thoroughfare != nil)
                        {
                            thoroughfare = pm.thoroughfare
                        }
                        
                        if pm.subThoroughfare == nil && pm.thoroughfare == nil
                        {
                            // if no thoroughfare available, then use the date
                            title = "Added \(NSDate())"
                        }
                        else
                        {
                            title = "\(subThoroughfare) \(thoroughfare)"
                        }

                        
                    }
                    
                    else {
                        println("Problem with the data received from geocoder")
                    }
                    
                }
                
                annotation.title = title
                
                self.map.addAnnotation(annotation)
                
                
                places.append(["name":title,"lat":"\(coordinate.latitude)","long":"\(coordinate.longitude)"])
                
            })
            
            
            
            

            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // remember to use the didUpdateLocations version
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var userLocation = locations[0] as! CLLocation
        
        moveMap(userLocation.coordinate.latitude, long: userLocation.coordinate.longitude)
        
        locationManager.stopUpdatingLocation()
    }
    
    func moveMap(lat:CLLocationDegrees, long:CLLocationDegrees)
    {
        // Set map to region
        
        var latitude:CLLocationDegrees = lat
        var longitude:CLLocationDegrees = long
        var latitudeDelta:CLLocationDegrees = 1
        var longitudeDelta:CLLocationDegrees = 1
        
        var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        
        var region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        map.setRegion(region, animated: true)
    }


}

