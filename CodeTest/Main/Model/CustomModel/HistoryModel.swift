//
//  HistoryModel.swift
//  CodeTest
//
//  Created by Alvis on 24/6/2021.
//

import Foundation

struct HistoryModel: ModelProtocol {
    public var index: Int?
    public var date: Date? = DateHelper.getCurrentDate()
    public var weather: WeatherMainModel?
    public var hexColorString: String?
}
