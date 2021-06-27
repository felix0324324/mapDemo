//
//  StorageManager.swift
//  CodeTest
//
//  Created by Alvis on 23/6/2021.
//

import Foundation
import KakaJSON

struct StorageManager {
    // MARK: Enum
    enum StorageKey: Int, CaseIterable {
        case HistoryLocations
        
        var description: String {
            return "KEY." + String(describing: self)
        }
    }
    
    // MARK: Save
    static private func save(storageKey: StorageKey, string: String) {
        let userDefaults = UserDefaults.standard
//        if withLangKey {
//            if var data: [String: String] = userDefaults.object(forKey: storageKey.description) as? [String: String] {
//                data.updateValue(string, forKey: SYLanguage.getCurrentLanguage().rawValue)
//                userDefaults.set(data, forKey: storageKey.description)
//            } else {
//                userDefaults.set([SYLanguage.getCurrentLanguage().rawValue: string], forKey: storageKey.description)
//            }
//        } else {
            userDefaults.set(string, forKey: storageKey.description)
//        }
        userDefaults.synchronize()
    }
    
    static func saveModel<Model: ModelProtocol>(storageKey: StorageKey, model: Model?) {
        guard let aJSONString = model?.kj.JSONString() else { return  }
        Self.save(storageKey: storageKey, string: aJSONString)
    }
    
    static func saveModelArray<Model: ModelProtocol>(storageKey: StorageKey, model: [Model]?) {
        guard let aJSONString = model?.kj.JSONString() else { return }
        Self.save(storageKey: storageKey, string: aJSONString)
    }
    
    // MARK: Load
    
    static func load(storageKey: StorageKey) -> String? {
        let userDefaults = UserDefaults.standard
//        if let data: [String: String] = userDefaults.value(forKey: storageKey.description) as? [String: String] {
//            return data[SYLanguage.getCurrentLanguage().rawValue]
//        }
        return userDefaults.object(forKey: storageKey.description) as? String
    }
    
    static func loadModel<Model: ModelProtocol>(storageKey: StorageKey, model: Model.Type) -> Model? {
        let aJSONString = Self.load(storageKey: storageKey)
        return aJSONString?.count ?? 0 > 0 ? aJSONString?.kj.model(model) : nil
    }
    
    static func loadModelArray<Model: ModelProtocol>(storageKey: StorageKey, model: Model.Type) -> [Model]? {
        let aJSONString = Self.load(storageKey: storageKey)
        return aJSONString?.count ?? 0 > 0 ? aJSONString?.kj.modelArray(model) : []
    }
}
