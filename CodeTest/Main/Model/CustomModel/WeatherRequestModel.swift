//
//  WeatherRequestModel.swift
//  CodeTest
//
//  Created by Alvis on 26/6/2021.
//

import Foundation

struct WeatherRequestModel: ModelProtocol {
    public var q: String? // HK, Hong Kong
    public var zip: String? // 94040,us
    public var appid: String? // 95d190a434083879a6398aafd54d9e73
    public var lang: String? // zh_tw
    public var lat: String?
    public var lon: String?
}
