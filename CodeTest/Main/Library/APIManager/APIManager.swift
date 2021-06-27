//
//  APIManager.swift
//
//  Copyright © 2020 Sunny Yeung. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class DataObject: NSObject {
    public required init(json: JSON) {
        super.init()
    }
    
    deinit {
        print("deint \(self)")
    }
}

// MARK: -
public struct EmptyParameter: ModelProtocol {
    public init() { }
}

// MARK: -
public struct APIManager {
    public typealias Completion<Result> = (CompletionStatus<Result>) -> Void
    
    public enum CompletionStatus<Result> {
        case Success(Result)
        case Fail(Int, JSON?)
        case Error(Int)
        case Cancel
    }
    
    public enum ConnectionType: String {
        case POST = "POST"
        case GET = "GET"
        case DEL = "DELETE"
        case PUT = "PUT"
    }
    
    public enum QueueType: String, CaseIterable {
        case Normal = "rootQueue"
        case Authorization = "authQueue"
    }
    
    // MARK: Static Public Value
    public static let TIMEOUT_INTERVAL: TimeInterval = 10
    
    // MARK: Static Private Value
    private static let m_oDateFormat: DateFormatter = DateFormatter()
    private static var m_oALSeesionsDic: [QueueType: Session] = [QueueType: Session]()
    
    // MARK: - ---Common Function---
    private static func getALSession(_ type: QueueType = .Normal) -> Session {
        guard let alamofireSession: Session = m_oALSeesionsDic[type] else {
            return configure(type)
        }
        return alamofireSession
    }
    
    private static func configure(_ resultSessionType: QueueType) -> Session {
        var currentSession: Session!
        
        QueueType.allCases.forEach {
            let configuration: URLSessionConfiguration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = URLSessionConfiguration.af.default.httpAdditionalHeaders
            configuration.timeoutIntervalForRequest = TIMEOUT_INTERVAL
            configuration.timeoutIntervalForResource = TimeInterval(TIMEOUT_INTERVAL * 2)
            let alamofireSession = Session(configuration: configuration, delegate: SessionDelegate(), rootQueue: DispatchQueue(label: "com.connectorManager.\($0.rawValue)"), interceptor: RequestHandler())
            m_oALSeesionsDic.updateValue(alamofireSession, forKey: $0)
            if $0 == resultSessionType {
                currentSession = alamofireSession
            }
        }
        
        m_oDateFormat.locale = Locale(identifier: "en_US_POSIX")
        m_oDateFormat.timeZone = TimeZone(identifier: "Asia/Hong_Kong")
        
        return currentSession
    }
    
    public static func cancelAllConnection() {
        m_oALSeesionsDic.forEach { $0.value.session.getAllTasks { $0.forEach { $0.cancel() } } }
    }
    
    public static func cancelConnection(serverURLArray: [ServerURL]) {
            m_oALSeesionsDic.forEach {
                $0.value.session.getAllTasks {
                $0.forEach {
                    if let aCurrentUELString = $0.currentRequest?.url?.absoluteString,
                       serverURLArray.filter({ aCurrentUELString.contains($0.rawValue) }).count > 0 {
                       $0.cancel()
                    }
                }
            }
        }
    }
    
    public static func request<PostData: Encodable, Result>(url: String, method: ConnectionType = .GET,
                                                            headers: HTTPHeaders? = nil, postData: PostData? = nil,
                                                            encoder: ParameterEncoder? = nil, queueType: QueueType = .Normal,
                                                            timeout: TimeInterval = TIMEOUT_INTERVAL, completion: Completion<Result>?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let completBlock: ((AFDataResponse<Data>) -> Void) = { (response: AFDataResponse<Data>) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            autoreleasepool {
                var parseToJSONFail: Bool = false
                let statusCode: Int = response.response?.statusCode ?? 0
                var jsonObject: JSON = JSON(response.data as Any)
                if jsonObject == .null, let resultData: Data = response.data {
                    parseToJSONFail = true
                    jsonObject = JSON(String(data: resultData, encoding: .utf8) ?? "")
                }
                
                switch response.error {
                case let error where error == nil:
                    var status: CompletionStatus<Result> = .Error(-1)
                    if let dataResult: Result = response.data as? Result {
                        status = .Success(dataResult)
                    } else if let jsonResult: Result = jsonObject as? Result, !parseToJSONFail {
                        status = .Success(jsonResult)
                    } else if let boolResult: Result = (jsonObject["success"].bool ?? (statusCode == 200)) as? Result {
                        // If result is Bool check json had "success" key, if not had "success" check status code is 200 or not.
                        status = .Success(boolResult)
                    }
                    
                    switch status {
                    case .Success:
                        print("\n----------------------------------------\nRequest: \(url)\nMethod: \(method)\nHeader: \(String(describing: response.request?.headers))\nData: \(String(describing: postData))\nResponse: \(jsonObject)")
                    default:
                        print("\n----------------------------------------\nRequest: \(url)\nMethod: \(method)\nHeader: \(String(describing: response.request?.headers))\nData: \(String(describing: postData))\nResponse: \(jsonObject)")
                    }
                    
                    completion?(status)
                case .sessionTaskFailed(let error) where (error as NSError).code == -999:
                    print("Cancel api: \(url)")
                    completion?(.Cancel)
                default:
                    print("\n----------------------------------------\nRequest: \(url)\nMethod: \(method)\nHeader: \(String(describing: response.request?.headers))\nData: \(String(describing: postData))\nError: \(String(describing: response.error?.localizedDescription))\nResponse: \(jsonObject)")
                    
                    if ![0, 500].contains(statusCode) {
                        completion?(.Fail(statusCode, jsonObject))
                    } else {
                        completion?(.Error(statusCode))
                    }
                }
            }
        }
        
        switch method {
        case .GET:
            getALSession(queueType).request(url, method: .get, parameters: postData, encoder: encoder ?? URLEncodedFormParameterEncoder.default, headers: headers) { request in
                request.timeoutInterval = timeout
            }.validate().responseHandler(completionHandler: completBlock)
        default:
            getALSession(queueType).request(url, method: HTTPMethod(rawValue: method.rawValue), parameters: postData, encoder: encoder ?? JSONParameterEncoder.default, headers: headers) { request in
                request.timeoutInterval = timeout
            }.validate().responseHandler(completionHandler: completBlock)
        }
    }
    
    public static func handleJSONArray<Model: DataObject>(_ modelClassType: Model.Type, _ resultAry: [JSON]?) -> [Model] {
        var dataAry: [Model] = [Model]()
        resultAry?.forEach({ (json: JSON) in
            dataAry.append(Model(json: json))
        })
        return dataAry
    }
}

// MARK: - RequestHandler & ResponseHandler
extension APIManager {
    public class RequestHandler: RequestInterceptor {
        public var m_iRetryLimit: Int {
            return 2
        }
    }
    
    public class ResponseHandler: ResponseSerializer {
        public let dataPreprocessor: DataPreprocessor
        public let emptyResponseCodes: Set<Int>
        public let emptyRequestMethods: Set<HTTPMethod>
        
        public init(dataPreprocessor: DataPreprocessor = JSONResponseSerializer.defaultDataPreprocessor,
                    emptyResponseCodes: Set<Int> = JSONResponseSerializer.defaultEmptyResponseCodes,
                    emptyRequestMethods: Set<HTTPMethod> = JSONResponseSerializer.defaultEmptyRequestMethods) {
            self.dataPreprocessor = dataPreprocessor
            self.emptyResponseCodes = emptyResponseCodes
            self.emptyRequestMethods = emptyRequestMethods
        }
        
        public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Data {
            guard error == nil else {
                switch error?.asAFError {
                case .responseValidationFailed(reason: _):
                    throw AFError.responseSerializationFailed(reason: .customSerializationFailed(error: error!))
                default:
                    throw error!
                }
            }
            
            guard var data = data, !data.isEmpty else {
                guard emptyResponseAllowed(forRequest: request, response: response) else {
                    throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
                }
                return Data()
            }
            
            data = try dataPreprocessor.preprocess(data)
            
            return data
       }
    }
}

extension DataRequest {
    @discardableResult
    public func responseHandler(completionHandler: @escaping (AFDataResponse<Data>) -> Void) -> Self {
        return response(queue: .main,
                        responseSerializer: APIManager.ResponseHandler(),
                        completionHandler: completionHandler)
    }
}
