//
//  MapViewController.swift
//  Tour de World
//
//  Created by taralika on 3/23/20.
//  Copyright © 2020 at. All rights reserved.
//

import CoreData
import MapKit

let REMOVE_PINS_LABEL = "Remove Pins"

class MapViewController: BaseViewController, MKMapViewDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var removePinsLabel: UILabel!
    
    var annotations = [MKPointAnnotation]()
    var annotation = MKPointAnnotation()
    var pins: [Pin] = []
    var dataController: DataController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        mapView.addGestureRecognizer(gestureRecognizer)
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem!.title = REMOVE_PINS_LABEL
        
        pins = fetchPins()
        if pins.count > 0
        {
            for pin in pins
            {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        showActivityIndicator()
        mapView.deselectAnnotation(annotations as? MKAnnotation, animated: false)
        hideActivityIndicator()
    }
        
    func fetchPins() -> [Pin]
    {
        showActivityIndicator()
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        do
        {
            let result = try dataController.viewContext.fetch(fetchRequest)
            pins = result
            hideActivityIndicator()
        }
        catch
        {
            showAlert(message: "Could not fetch pins.", title: "Error")
            hideActivityIndicator()
        }
        return pins
    }
    
    @objc func handleLongPress(gestureReconizer: UIGestureRecognizer)
    {
        if gestureReconizer.state == .began
        {
            let location = gestureReconizer.location(in: mapView)
            let coordinate = mapView.convert(location,toCoordinateFrom: mapView)
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            
            let geocoder = CLGeocoder()
            let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geocoder.reverseGeocodeLocation(clLocation)
            { placeMarks, error in
                DispatchQueue.main.async
                {
                    if let placeMark = placeMarks?.first
                    {
                        if (placeMark.locality != nil && placeMark.administrativeArea != nil)
                        {
                            pin.locationName = (placeMark.locality ?? "") + ", " + (placeMark.administrativeArea ?? "")
                            print("pin location = " + (pin.locationName ?? "No Name"))
                        }
                    }
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            mapView.addAnnotation(annotation)
            do
            {
                try dataController.viewContext.save()
            }
            catch
            {
                showAlert(message: "Could not store the pin.", title: "Error")
            }
            pins.append(pin)
            mapView.reloadInputViews()
        }
    }
        
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        guard annotation is MKPointAnnotation else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
        }
        else
        {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if isEditing, let viewAnnotation = view.annotation
        {
            for pin in pins
            {
                if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude
                {
                    dataController.viewContext.delete(pin)
                }
            }
            
            do
            {
                try dataController.viewContext.save()
            }
            catch
            {
                showAlert(message: "Could not remove pin.", title: "Error")
            }
            mapView.removeAnnotation(viewAnnotation)
            return
        }
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        controller.latitude = view.annotation?.coordinate.latitude ?? 0.0
        controller.longitude = view.annotation?.coordinate.longitude ?? 0.0
        for pin in pins
        {
            if pin.latitude == view.annotation?.coordinate.latitude && pin.longitude == view.annotation?.coordinate.longitude
            {
                controller.pin = pin
                controller.title = pin.locationName
            }
        }
        
        controller.dataController = dataController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func setEditing(_ editing:Bool, animated:Bool)
    {
        super.setEditing(editing, animated: animated)
        if (self.isEditing)
        {
            toolBar.isHidden = false
            removePinsLabel.isHidden = false
            self.editButtonItem.title = "Done"
        }
        else
        {
            toolBar.isHidden = true
            removePinsLabel.isHidden = true
            self.editButtonItem.title = REMOVE_PINS_LABEL
        }
    }
}
