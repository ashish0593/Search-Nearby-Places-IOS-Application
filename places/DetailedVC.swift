//
//  DetailedViewController.swift
//  places
//
//  Created by Ashish Verma on 11/7/17.
//  Copyright © 2017 Ashish Verma. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class DetailedVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var detailedMapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var restaurantsBtn: UIButton!
    @IBOutlet weak var loungeBarBtn: UIButton!
    @IBOutlet weak var coffeeBtn: UIButton!
    
    //Changes tableView data for Restaurants Nearby
    @IBAction func restaurantsBtnPrsd(_ sender: Any) {
        fetchLocalData(category: "Restaurants")
    }
    //Changes tableView data for Bar Nearby
    @IBAction func loungeBarBtnPrsd(_ sender: Any) {
        fetchLocalData(category: "Bar")
    }
    //Changes tableView data for Coffee Nearby
    @IBAction func coffeeBtnPrsd(_ sender: Any) {
        fetchLocalData(category: "Coffee")
    }
    
    var mapData: MKMapItem!
    var selectedPin:MKPlacemark? = nil
    var responseResult : [MKMapItem]! = nil
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Track user location
        detailedMapView.delegate = self
        detailedMapView.userTrackingMode = MKUserTrackingMode.follow
        detailedMapView.showsUserLocation = true
        //Get data from segue and drop custom pin on MKplacemark object
        let customPlacemark = mapData.placemark
        dropPinZoomIn(placemark: customPlacemark)
        //Fetch Initial data for tableView
        fetchLocalData(category: "Restaurants")
        //setting delegate for tableView
        tableView.delegate = self
        tableView.dataSource = self
        //custom cell class for tableView cell
        self.tableView.register(NearbyCell.self, forCellReuseIdentifier: "NearbyCell")
    }
    //creates a custom MKLocalSearchRequest and gets MKLocalSearchResponse
    func fetchLocalData(category: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = category
        request.region = detailedMapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("There was an error searching for: \(String(describing: request.naturalLanguageQuery)) error: \(String(describing: error))")
                return
            }
            self.responseResult = response.mapItems
            self.tableView.reloadData()
        }
        return
    }
    //itterate the data inside the tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "NearbyCell")!
        tableCell.textLabel?.numberOfLines = 0
        tableCell.textLabel?.lineBreakMode = .byWordWrapping
        tableCell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        let eachResponse = responseResult[indexPath.row]
        var customAddress:String? = ""
        if((eachResponse.name) != nil){
            customAddress = customAddress! + eachResponse.name!
        }
        if(eachResponse.phoneNumber != nil){
            customAddress = customAddress! + "\n" + "\(eachResponse.phoneNumber!)"
        }
        if(eachResponse.url != nil){
            customAddress = customAddress! + "\n" + "\(eachResponse.url!)"
        }
        tableCell.textLabel?.text = customAddress
        return tableCell
    }
    //returns number of rows for the tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(self.responseResult)
        if(self.responseResult != nil){
            return self.responseResult!.count
        } else {
            return 0
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: .zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: [])
        button.addTarget(self, action: #selector(MainVC.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }

}

//Drops Cutsom Pin Annotation In the mapView
extension DetailedVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        detailedMapView.removeAnnotations(detailedMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        detailedMapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        detailedMapView.setRegion(region, animated: true)
        
    }
}

