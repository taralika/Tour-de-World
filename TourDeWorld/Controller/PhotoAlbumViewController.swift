//
//  PhotoAlbumViewController.swift
//  Tour de World
//
//  Created by taralika on 3/23/20.
//  Copyright © 2020 at. All rights reserved.
//

import CoreData
import MapKit

class PhotoAlbumViewController: BaseViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noPhotosLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    let annotation = MKPointAnnotation()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var page: Int = 0
    var photosPerRow = 0
    var photos: [Photo] = []
    var flickrPhotos: [FlickrPhoto] = []
    var pin: Pin!
    var dataController: DataController!
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
        self.photoCollection.delegate = self
        
        flickrPhotos = fetchFlickrPhotos()        
        if flickrPhotos.count > 0
        {
            for flickrPhoto in flickrPhotos
            {
                flickrPhotos.append(flickrPhoto)
                photoCollection.reloadData()
            }
        }
        else
        {
            getPhotos()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        showSelectedPin()
        getPhotos()
    }
    
    func fetchFlickrPhotos() -> [FlickrPhoto]
    {
        showActivityIndicator()
        let fetchRequest: NSFetchRequest<FlickrPhoto> = FlickrPhoto.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        do
        {
            let result = try dataController.viewContext.fetch(fetchRequest)
            flickrPhotos = result
            hideActivityIndicator()
        }
        catch
        {
            showAlert(message: "Could not fetch Flickr photo.", title: "Error")
            hideActivityIndicator()
        }
        
        return flickrPhotos
    }
        
    @IBAction func loadNewCollection(_ sender: UIBarButtonItem)
    {
        newCollectionButton.isEnabled = false
        clearPhotos()
        photos = []
        flickrPhotos = []
        getPhotos()
        photoCollection.reloadData()
    }
    
    // load random photos
    func getPhotos()
    {
        showActivityIndicator()
        PhotoRequests.searchPhotos(latitude: latitude, longitude: longitude, page: page, completion:
        { (photos, error) in
            if (photos != nil)
            {
                if photos?.pages == 0
                {
                    self.noPhotosLabel.isHidden = false
                    self.newCollectionButton.isEnabled = false
                    self.hideActivityIndicator()
                }
                else
                {
                    self.photos = (photos?.photo)!
                    self.page = Int.random(in: 1...photos!.pages)
                    self.getImageURL()
                    self.photoCollection.reloadData()
                    self.hideActivityIndicator()
                }
            }
            else
            {
                self.showAlert(message: "Could not fetch photos.", title: "Error", error: error)
                self.newCollectionButton.isEnabled = true
                self.hideActivityIndicator()
            }
        })
    }
    
    func getImageURL()
    {
        for photo in photos
        {
            let flickrPhoto = FlickrPhoto(context: dataController.viewContext)
            flickrPhoto.imageUrl = photo.urlSq
            flickrPhoto.pin = pin
            flickrPhotos.append(flickrPhoto)
            do
            {
                try self.dataController.viewContext.save()
            }
            catch
            {
                self.showAlert(message: "Could not fetch image URL.", title: "Error")
            }
        }
        
        DispatchQueue.main.async
        {
            self.photoCollection.reloadData()
        }
    }
        
    func clearPhotos()
    {
        for flickrPhoto in flickrPhotos
        {
            dataController.viewContext.delete(flickrPhoto)
            do
            {
                try self.dataController.viewContext.save()
            }
            catch
            {
                self.showAlert(message: "Could not remove photos.", title: "Error")
            }
        }
    }
            
    func showSelectedPin()
    {
        mapView.removeAnnotations(mapView.annotations)
        annotation.coordinate.latitude = latitude
        annotation.coordinate.longitude = longitude
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: true)
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
        
        pinView?.isDraggable = true
        return pinView
    }
    
    // allow dragging the pin to a new coordinate on the map
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState)
    {
        switch newState
        {
            case .canceling, .ending:

                guard let coordinate = view.annotation?.coordinate else { preconditionFailure() }
                pin.latitude = coordinate.latitude
                pin.longitude = coordinate.longitude
                clearPhotos()
                photos = []
                flickrPhotos = []
                getPhotos()
                photoCollection.reloadData()

            default: break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return flickrPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        self.newCollectionButton.isEnabled = false
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        let cellImage = flickrPhotos[indexPath.row]
        
        if cellImage.image != nil
        {
            cell.photoImageView.image = UIImage(data: cellImage.image!)
            self.newCollectionButton.isEnabled = true
        }
        else
        {
           cell.photoImageView.image = UIImage(named: "ImagePlaceholder")
            
            if cellImage.imageUrl != nil
            {
                let url = URL(string: cellImage.imageUrl ?? "")
                PhotoRequests.downloadPhoto(url: url!)
                { (data, error) in
                    if (data != nil)
                    {
                        DispatchQueue.main.async
                        {
                            cellImage.image = data
                            cellImage.pin = self.pin
                            do
                            {
                                try self.dataController.viewContext.save()
                            }
                            catch
                            {
                                self.showAlert(message: "Could not save photo.", title: "Error")
                            }
                            
                            DispatchQueue.main.async
                            {
                                cell.photoImageView?.image = UIImage(data: data!)
                            }
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                        {
                            self.showAlert(message: "Could not download photo.", title: "Error")
                        }
                    }
                    
                    DispatchQueue.main.async
                    {
                        self.newCollectionButton.isEnabled = true
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let alertVC = UIAlertController(title: "Remove", message: "Want to remove this photo?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (action: UIAlertAction) in
            let flickrPhoto = self.flickrPhotos[indexPath.row]
            self.dataController.viewContext.delete(flickrPhoto)
            self.flickrPhotos.remove(at: indexPath.row)
            
            do
            {
                try self.dataController.viewContext.save()
            }
            catch
            {
                self.showAlert(message: "Could not remove photo.", title: "Error")
            }
        
            self.photoCollection.reloadData()
        }))
            
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
                alertVC.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertVC, animated: true)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
         let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
         let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(photosPerRow - 1))
         let size = Int((photoCollection.bounds.width - totalSpace) / CGFloat(photosPerRow))
         return CGSize(width: size, height: size)
    }
    
    override func viewWillLayoutSubviews()
    {
        guard let flowLayout = photoCollection.collectionViewLayout as? UICollectionViewFlowLayout else
        {
            return
        }
        
        if UIDevice.current.orientation == .portrait
        {
            photosPerRow = 3
        }
        else
        {
            photosPerRow = 5
        }
        
        flowLayout.invalidateLayout()
    }
}
