//
//  PhotoData.swift
//  Tour de World
//
//  Created by taralika on 3/23/20.
//  Copyright © 2020 at. All rights reserved.
//

struct PhotoData: Codable
{
    let photos: Photos
    let stat: String
}

struct Photos: Codable
{
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photo: [Photo]
    
    enum CodingKeys: String, CodingKey
    {
        case page, pages, total, photo
        case perPage = "perpage"
    }
}

struct Photo: Codable
{
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    let urlSq: String
    
    enum CodingKeys: String, CodingKey
    {
        case id, owner, secret, server, farm, title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
        case urlSq = "url_sq"
    }
}
