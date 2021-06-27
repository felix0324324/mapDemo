//
//  Weather.swift
//  CodeTest
//
//  Created by Alvis on 26/6/2021.
//

import MapKit
import Foundation
import KakaJSON


// MARK: - Welcome
struct WeatherMainModel: ModelProtocol {
    public var coord: Coord?
    public var weather: [Weather]?
    public var base: String?
    public var main: Main?
    public var visibility: Int?
    public var wind: Wind?
    public var clouds: Clouds?
    public var dt: Int?
    public var sys: Sys?
    public var timezone, id: Int?
    public var name: String?
    public var cod: Int?
    
    public var locationCoordinate2D: CLLocationCoordinate2D? {
        return CLLocationCoordinate2D.init(latitude: coord?.lat ?? 0, longitude: coord?.lon ?? 0)
    }
}

extension CLLocationCoordinate2D: Equatable {}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
}
// MARK: - Clouds
struct Clouds: ModelProtocol {
    public var all: Int?
}

// MARK: - Coord
struct Coord: ModelProtocol {
    public var lon, lat: Double?
}

// MARK: - Main
struct Main: ModelProtocol {
    public var temp, feelsLike, tempMin, tempMax: Double?
    public var pressure, humidity: Int?
}

// MARK: - Sys
struct Sys: ModelProtocol {
    public var type, id: Int?
    public var country: String?
    public var sunrise, sunset: Int?
}

// MARK: - Weather
struct Weather: ModelProtocol {
    public var id: Int?
    public var main, weatherDescription, icon: String?
}

// MARK: - Wind
struct Wind: ModelProtocol {
    public var speed: Double?
    public var deg: Int?
}

