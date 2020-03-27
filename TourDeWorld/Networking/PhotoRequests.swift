//
//  PhotoRequests.swift
//  Tour de World
//
//  Created by taralika on 3/23/20.
//  Copyright © 2020 at. All rights reserved.
//

import Foundation

class PhotoRequests
{
    enum Endpoints
    {
        static let base = "https://api.flickr.com/services/rest"
        static let photoSearch = "?method=flickr.photos.search"
        
        case getPhotos(Double, Double, Int)
        
        var stringValue: String
        {
            switch self
            {
                case .getPhotos(let latitude, let longitude, let page):
                    return Endpoints.base + Endpoints.photoSearch + "&extras=url_sq" + "&api_key=\(Constants.FLICKR_API_KEY)" + "&lat=\(latitude)" + "&lon=\(longitude)" + "&per_page=30" + "&page=\(page)" + "&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL
        {
            return URL(string: stringValue)!
        }
    }
        
    class func searchPhotos(latitude: Double, longitude: Double, page: Int, completion: @escaping (Photos?, Error?) -> Void)
    {
        var request = URLRequest(url: Endpoints.getPhotos(latitude, longitude, page).url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request)
        { data, response, error in
            if error != nil
            {
                completion(nil, error)
            }
            guard let data = data else
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
                return
            }
            do
            {
                let response = try JSONDecoder().decode(PhotoData.self, from: data)
                DispatchQueue.main.async
                {
                    completion(response.photos, nil)
                }
            }
            catch
            {
                DispatchQueue.main.async
                {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
        
    class func downloadPhoto(url: URL, completion: @escaping (Data?, Error?) -> Void)
    {
        let task = URLSession.shared.dataTask(with: url)
        { data, response, error in
            guard let data = data else
            {
                completion(nil, error)
                return
            }
            
            completion(data, nil)
        }
        
        task.resume()
    }
}
