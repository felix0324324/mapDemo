//
//  APIManager+ServerURL.swift
//
//
//  Copyright © 2020 Data Technology. All rights reserved.
//

//import Foundation
import Alamofire
import KakaJSON
import SwiftyJSON

typealias ServerConnector = APIManager

public enum ServerURL: RawRepresentable {
    case Unknown
    case Weather(WeatherURL)
    
    public var rawValue: String {
        var aURLString = ""
        switch self {
        case .Weather(let url):
            aURLString = PrefixDomain.OpenWeatherMap.rawValue 
            aURLString += url.rawValue
        default:
            aURLString = ""
        }
        return aURLString
    }
    
    public init(rawValue: String) {
        if let aURL: WeatherURL = WeatherURL(rawValue: rawValue) {
           self = .Weather(aURL)
        } else {
            self = .Unknown
        }
    }
    
    public var isSuccess: Bool { return self.rawValue.count >= 0 }
}

// MARK: Domain URL Enum
private enum PrefixDomain: String {
    case OpenWeatherMap = "https://api.openweathermap.org"
//        ?zip=94041&appid=95d190a434083879a6398aafd54d9e73
}
public enum WeatherURL: String {
//    case None = ""
    case Weather = "/data/2.5/weather"
}

// MARK: -

// MARK: -
extension APIManager {
    static private func request<PostData: Encodable,
                                Result>(url: ServerURL, method: ConnectionType = .GET,
                                        headers: HTTPHeaders? = nil, postData: PostData? = nil,
                                        encoder: ParameterEncoder? = nil, queueType: QueueType = .Normal,
                                        timeout: TimeInterval = TIMEOUT_INTERVAL,
                                        completion: APIManager.Completion<Result>?) {
        request(url: url.rawValue, method: method, headers: headers, postData: postData, encoder: encoder, queueType: queueType, timeout: timeout) { (result: CompletionStatus<Result>) in
            completion?(result)
            switch result {
            case .Error(let errorCode),
                 .Fail(let errorCode, _):
                break
            default:
                break
            }
        }
    }
    
    static private func requestModel<PostData: Encodable,
                                     Model: ModelProtocol,
                                     Result>(url: ServerURL, method: ConnectionType = .GET,
                                             headers: HTTPHeaders? = nil, postData: PostData? = nil,
                                             encoder: ParameterEncoder? = nil, queueType: QueueType = .Normal,
                                             timeout: TimeInterval = TIMEOUT_INTERVAL, modelType: Model.Type,
                                             completion: APIManager.Completion<Result>?) {
        request(url: url, method: method, headers: headers, postData: postData, encoder: encoder, queueType: queueType, timeout: timeout) { (result: CompletionStatus<Data>) in
            switch result {
            case .Success(let data):
                DispatchQueue.global(qos: .default).async {
                    var tempResult: Result?
                    
                    switch Result.self {
                    case is Array<Model>.Type:
                        let tmpAry = data.kj.modelArray(modelType)
                        if tmpAry.count > 0 {
                            tempResult = tmpAry as? Result
                        }
                    default:
                        tempResult = data.kj.model(modelType) as? Result
                    }

                    DispatchQueue.main.async {
                        guard let aResult: Result = tempResult else {
                            completion?(.Error(-1))
                            return
                        }

                        completion?(.Success(aResult))
                    }
                }
            case .Fail(let errorCode, let json):
                completion?(.Fail(errorCode, json))
            case .Error(let errorCode):
                completion?(.Error(errorCode))
            case .Cancel:
                completion?(.Cancel)
            }
        }
    }
    
    static func weather(model: WeatherRequestModel, completion: APIManager.Completion<WeatherMainModel>?) {
        requestModel(url: .Weather(.Weather), method: .GET, postData: model, modelType: WeatherMainModel.self, completion: completion)
        
    }
}
